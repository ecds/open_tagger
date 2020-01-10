class SearchableEntitiesSerializer < ActiveModel::Serializer
  # has_many :property_labels
  attributes :attrs

  def attrs
    object[:_source].id
  end
end
