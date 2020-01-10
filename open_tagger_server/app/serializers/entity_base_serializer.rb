class EntityBaseSerializer < ActiveModel::Serializer
  attributes :id, :label, :properties, :suggestion, :flagged, :description, :type_label
end
