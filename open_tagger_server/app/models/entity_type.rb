class EntityType < ApplicationRecord
  # has_many :entities
  # has_many :people
  # has_many :places
  has_many :entity_properties
  has_many :property_labels, through: :entity_properties
end
