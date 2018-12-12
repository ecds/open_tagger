class CollectionSerializer < ActiveModel::Serializer
  belongs_to :repository
  attributes :id, :label
end
