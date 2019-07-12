class EntitySerializer < ActiveModel::Serializer
  # has_many :property_labels
  belongs_to :entity_type
  attributes :id, :label, :properties, :suggestion, :description
end
