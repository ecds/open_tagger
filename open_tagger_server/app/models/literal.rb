class Literal < ApplicationRecord
  belongs_to :entity, optional: true
  has_one :entity_type, through: :entity

  scope :by_text_and_type, lambda { |text, type|
    where(text: text)
    .joins(entity: :entity_type)
    .where(entity_types: { label: type })
  }

  def unassigned
    entity.nil?
  end
end


