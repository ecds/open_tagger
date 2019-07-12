class EntityType < ApplicationRecord
  has_many :entities
  # has_many :people
  # has_many :places
  has_many :type_properties
  has_many :properties, through: :type_properties
end
