class Entity < ApplicationRecord
  searchkick callbacks: :async
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

    {
      label: label,
      e_type: e_type
    }.merge(properties)
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