class TypeProperty < ApplicationRecord
  belongs_to :property
  belongs_to :entity_type
end

