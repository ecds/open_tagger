class EntityTypeSerializer < ActiveModel::Serializer
  # has_many :property_labels
  attributes :id, :label, :pretty_label, :plural
end
