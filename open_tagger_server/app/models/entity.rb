class Entity < ApplicationRecord
  include PgSearch

  belongs_to :entity_type
  has_many :literals
  # has_many :letter_entities
  # has_many :letters, through: :letter_entities
  has_many :links

  scope :by_type, lambda { |type|
    joins(:entity_type)
    .where('entity_types.label = ?', type)
  }

  def by_type(type)
    where(entity_type: EntityType.find_by(lable: type))
  end

  pg_search_scope :search_by_label,
                  against: :label,
                  ignoring: :accents,
                  using: {
                    tsearch: {
                      prefix: true,
                      any_word: true
                    }
                  }

  def entity_properties
    entity_type.entity_properties
  end

  def letters
    literals.collect(&:letters).flatten
  end

  # private

Entity.all.each do |e|
  next if e.properties.nil?
  if e.properties['profile']
    e.description = e.properties['profile']
    e.properties.delete('profile')
  elsif e.properties['description']
    e.description = e.properties['description']
    e.properties.delete('description')
  end
  e.save
end

end
