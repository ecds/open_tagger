class Entity < ApplicationRecord
  include PgSearch::Model
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  validates :legacy_pk, presence: true
  before_validation :add_legacy_pk
  before_save :remove_div
  before_save :set_public
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

  scope :by_type, lambda { |type|
    joins(:entity_type)
    .where('entity_types.label = ?', type)
  }

  scope :get_by_label, lambda { |label|
    where('entities.label = ?', label)
  }

  scope :is_public?, -> {
    where(is_public: true)
  }

  # def by_type(type)
  #   where(entity_type: EntityType.find_by(lable: type))
  # end

  index_name Rails.application.class.parent_name.underscore
  document_type self.name.downcase

  pg_search_scope :search_by_label,
                  against: {
                    label: 'A',
                    properties: 'D'
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
  settings index: { number_of_shards: 1 } do
    mapping dynamic: false do
      indexes :label, type: :text#, analyzer: 'english'
      indexes :properties, dynamic: true do
      end
    end
  end
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

    def remove_div
      if label.present? && label.start_with?('<div>') && label.end_with?('</div>')
        lable = label[5..-7]
      end
    end

    def set_public
      if public_letters_hash.empty?
        self.is_public = false
      else
        self.is_public = true
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