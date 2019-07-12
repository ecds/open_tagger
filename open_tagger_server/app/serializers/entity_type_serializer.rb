class EntityTypeSerializer < ActiveModel::Serializer
  # has_many :property_labels
  attributes :id, :label
end
