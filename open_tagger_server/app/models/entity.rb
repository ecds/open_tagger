class Entity < ApplicationRecord
  searchkick callbacks: :async, word_middle: [:label]
  include PgSearch::Model
  serialize :properties, HashSerializer

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

    false
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

  def search_data
    return { label: label } if properties.nil?

    properties_to_index = {
      profile: properties.profile,
      description: properties.description,
      alternate_spellings: properties.alternate_spellings,
      last_name: properties.last_name,
      first_name: properties.first_name,
      alternate_names_spellings: properties.alternate_names_spellings,
      alternate_names_spelling: properties.alternate_names_spelling,
      notes: properties.notes,
      place: properties.place,
      author: properties.author,
      translator: properties.translator,
      publication_information: properties.publication_information,
      proposal: properties.proposal,
      beckett_digital_manuscript_project: properties.beckett_digital_manuscript_project,
      authors: properties.authors,
      comment: properties.comment,
      publication: properties.publication,
      publication_format: properties.publication_format,
      director: properties.director,
      event_type: properties.event_type,
      place_date: properties.place_date,
      performed_by: properties.performed_by,
      attended_with: properties.attended_with,
      alternative_spellings: properties.alternative_spellings,
      cast: properties.cast,
      city: properties.city,
      data: properties.data,
      staff: properties.staff,
      reason: properties.reason,
      theatre: properties.theatre,
      response: properties.response,
      personnel: properties.personnel,
      staging_beckett: properties.staging_beckett,
      owner: properties.owner,
      artist: properties.artist,
      location: properties.location,
      artist_alternate_spellings: properties.artist_alternate_spellings,
      owner_location_accession_number_current: properties.owner_location_accession_number_current,
      owner_location_accession_number_contemporaneous: properties.owner_location_accession_number_contemporaneous,
      comments: properties.comments,
      translated_into: properties.translated_into,
      translated_title: properties.translated_title,
      composer: properties.composer,
      alternative_titles: properties.alternative_titles,
      porposal: properties.porposal
    }

    {
      label: label,
      e_type: e_type,
      legacy_pk: legacy_pk,
      is_public: is_public
    }.merge(properties_to_index)
  end

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