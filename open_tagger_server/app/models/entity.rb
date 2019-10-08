class Entity < ApplicationRecord
  include PgSearch::Model
  validates :legacy_pk, presence: true
  before_validation :add_legacy_pk
  before_save :remove_div
  # serialize :properties, HashSerializer
  # store_accessor :properties, :links

  belongs_to :entity_type

  has_many :literals
  has_many :alternate_spellings

  has_many :mentions
  has_many :letters, through: :mentions

  has_many :letter_place_written
  has_many :letters_written_to_place, through: :letter_place_written, source: :letter

  has_many :letter_recipients
  has_many :letters_written_to_person, through: :letter_recipients, source: :entity

  scope :by_type, lambda { |type|
    joins(:entity_type)
    .where('entity_types.label = ?', type)
  }

  scope :get_by_label, lambda { |label|
    where('entities.label = ?', label)
  }

  # def by_type(type)
  #   where(entity_type: EntityType.find_by(lable: type))
  # end

  pg_search_scope :search_by_label,
                  against: :label,
                  associated_against: {
                    alternate_spellings: :label
                  },
                  ignoring: :accents,
                  using: {
                    tsearch: {
                      prefix: true,
                      any_word: true
                    }
                  }

  # def entity_properties
  #   entity_type.entity_properties
  # end

  def type_label
    entity_type.pretty_label
  end

  def letters_list
    letters.collect(&:id).flatten
  end

  def alternate_spelling_list
    alternate_spellings.collect(&:label)
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
