class PropertyLabel < ApplicationRecord
  has_many :entity_properties
  has_many :entity_types, through: :entity_properties
end
