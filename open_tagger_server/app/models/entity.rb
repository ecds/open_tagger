class Entity < ApplicationRecord
  searchkick
  include PgSearch::Model
  # include Elasticsearch::Model
  # include Elasticsearch::Model::Callbacks
  validates :legacy_pk, presence: true
  before_validation :add_legacy_pk
  before_save :scrub_html
  before_save :set_public
  before_create :add_properties
  # serialize :properties, HashSerializer
  # store_accessor :properties, :links

  attr_accessor :public_letters_hash

  belongs_to :entity_type

  has_many :literals
  has_many :alternate_spellings

  has_many :mentions
  has_many :letters, through: :mentions

  has_many :letter_place_sent
  has_many :places_sent, through: :letter_place_sent, source: :letter

  has_many :letter_senders
  has_many :senders, through: :letter_senders, source: :letter

  has_many :letter_place_written
  has_many :letters_written_to_place, through: :letter_place_written, source: :letter

  has_many :letter_recipients
  has_many :letters_written_to_person, through: :letter_recipients, source: :letter

  enum e_type: {
    person: 0,
    organization: 1,
    place: 2,
    production: 3,
    writing: 4,
    translating: 5,
    reading: 6,
    attendance: 7,
    music: 8,
    publication: 9,
    public_event: 10,
    work_of_art: 11
  }

  scope :by_type, lambda { |type|
    joins(:entity_type)
    .where('entity_types.label = ?', type)
  }

  scope :get_by_label, lambda { |label|
    where('entities.label = ?', label)
  }

  scope :is_public?, -> {
    where(is_public: true).where.not(legacy_pk: 99999999)
  }

  # def by_type(type)
  #   where(entity_type: EntityType.find_by(lable: type))
  # end

  def deletable
    if legacy_pk == 88888888 || legacy_pk == 99999999
      return false if letters.present?
      return false if places_sent.present?
      return false if letters_written_to_place.present?
      return false if letters_written_to_person.present?
      return true
    end

    return false
  end

  # index_name Rails.application.class.parent_name.underscore
  # document_type self.name.downcase

  pg_search_scope :search_by_label,
                  against: {
                    label: 'A',
                    properties: 'B'
                  },
                  # associated_against: {
                  #   alternate_spellings: :label
                  # },
                  ignoring: :accents,
                  using: {
                    tsearch: {
                      prefix: true,
                      any_word: true
                    },
                    dmetaphone: {any_word: true, sort_only: true}
                  }

  # https://medium.com/@divyanshu.verma1993/configuring-elasticsearch-on-rails-8bcbe973e9e7
  # settings index: { number_of_shards: 1 } do
  #   mapping dynamic: false do
  #     indexes :label, type: :text, boost: 50#, analyzer: 'english'
  #     indexes :properties, boost: 40, dynamic: true do
  #     end
  #   end
  # end

  # def self.essearch(query, options = {})
  #  properties = Entity.all.map { |e| e.properties.keys}.flatten.uniq.map {|p| "properties.#{p}"}
  #  properties.push('label')
  #   __elasticsearch__.search(
  #     {
  #       query: {
  #         multi_match: {
  #           query: query,
	#     type: 'cross_fields',
	#     fields: properties
  #         }
  #       }
  #     }.merge(options)
  #   )
  # end

  # def self.esfilter(query, options = {})
  #   fields = ["label", "properties.links", "properties.media", "properties.profile", "properties.last_name", "properties.first_name", "properties.life_dates", "properties.description", "properties.alternate_names_spellings", "properties.alternate_names_spelling", "properties.alternate_spellings", "properties.coordinates", "properties.notes", "properties.place", "properties.author", "properties.translator", "properties.publication_information", "properties.date", "properties.proposal", "properties.beckett_digital_manuscript_project", "properties.owner", "properties.artist", "properties.location", "properties.alternative_spellings", "properties.artist_alternate_spellings", "properties.owner_location_accession_number_current", "properties.owner_location_accession_number_contemporaneous", "properties.authors", "properties.comment", "properties.publication", "properties.publication_format", "properties.director", "properties.event_type", "properties.place_date", "properties.performed_by", "properties.attended_with", "properties.cast", "properties.city", "properties.data", "properties.staff", "properties.reason", "properties.theatre", "properties.response", "properties.personnel", "properties.staging_beckett", "properties.comments", "properties.translated_into", "properties.translated_title", "properties.composer", "properties.alternative_titles", "properties.porposal"]

  #   query_options = {
  #     bool: {
  #       must: [{
  #         multi_match: {
  #           query:      query,
	#     #type: 'most_fields',
  #           fields: fields,
	#     fuzziness: 'AUTO'
  #         }
  #       }]
  #     }
  #   }
  #   if options[:filter]
  #     query_options[:bool][:filter] = [{
  #       term: {
	# 	'label': options.delete(:filter).downcase
  #       }
  #     }]
  #   end


  #   __elasticsearch__.search(
  #     {
  #       query: query_options
  #     }.merge(options)
  #   )
  # end
  # def entity_properties
  #   entity_type.entity_properties
  # end

  # settings index: { number_of_shards: 1 } do
  #   mapping dynamic: false do
  #     indexes :label, analyzer: 'english'
  #     indexes :properties, analyzer: 'english'
  #   end
  # end

  def type_label
    entity_type.pretty_label
  end

  def letters_list
    letters.collect(&:id).flatten
  end

  def public_letters_hash
    public_letters = letters._public + places_sent._public + senders._public + letters_written_to_place._public + letters_written_to_person._public
    public_letters.reject! {|l| l.recipients.count == 0}
    public_letters.uniq.sort_by(&:date).map { |letter| {
      id: letter.id,
      date: letter.formatted_date,
      recipients: letter.recipients.map { |r| {
        id: r.id,
        name: r.label
      }}
    }}
  end

  def alternate_spelling_list
    alternate_spellings.collect(&:label)
  end

  def not_public?
    # if letters._public.empty? || letters_written_to_person._public.empty? || letters_written_to_person._public.empty?
    #   return false
    # else
    #   return true
    # end
    public_letters_hash.empty?
  end

  private

    def add_legacy_pk
      if legacy_pk.nil?
        self.legacy_pk = 99999999
      end
    end

    def what
      entities = Entity.where(legacy_pk: 99999999)
      File.open('entities.txt', 'a') do |f|
        entities.each do |e|
          f << "#{p.label}\n"
        end
      end
    end

    def scrub_html
      return if label.nil?
      scrubber = Rails::Html::PermitScrubber.new
      scrubber.tags = %w(i b)
      self.label = Loofah.fragment(self.label).scrub!(scrubber).to_html
    end

    def set_public
      if public_letters_hash.empty?
        self.is_public = false
      else
        self.is_public = true
      end
    end

    def add_properties
      if self.properties.nil?
        self.properties = {}
      end
      self.entity_type.properties.each do |p|
        if !self.properties.has_key? p
          if p.prop_type == 'a'
            self.properties[p.label] = []
          elsif p.prop_type == 'h'
            self.properties[p.label] = {}
          elsif p.prop_type == 's'
            self.properties[p.label] = ''
          end
        end
      end
    end
# Entity.all.each do |e|
#   next if e.properties.nil?
#   if e.properties['profile']
#     e.description = e.properties['profile']
#     e.properties.delete('profile')
#   elsif e.properties['description']
#     e.description = e.properties['description']
#     e.properties.delete('description')
#   end
#   e.save
# end

end