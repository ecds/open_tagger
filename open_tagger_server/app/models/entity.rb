class Entity < ApplicationRecord
  include PgSearch

  belongs_to :entity_type
  # has_one :person
  # has_one :place
  has_many :literals
  has_many :letter_entities
  has_many :letters, through: :letter_entities

  # before_save :_get_formal_name

  scope :by_type, lambda { |type|
    joins(:entity_type)
    .where('entity_types.label = ?', type)
  }

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

  private

    def _get_formal_name
      return if !self.person
      self.label = self.person.formal_name
    end
end
