class EntityProperty < ApplicationRecord
  belongs_to :entity_type
  belongs_to :property_label
end
