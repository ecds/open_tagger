class EntitySearchSerializer < ActiveModel::Serializer
  attributes :id, :label, :properties, :legacy_pk, :type_label
end
