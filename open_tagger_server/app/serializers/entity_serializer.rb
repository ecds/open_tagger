class EntitySerializer < ActiveModel::Serializer
  # has_many :property_labels
  attributes :id, :label, :properties, :suggestion
end
