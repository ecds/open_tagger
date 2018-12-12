class PlaceSerializer < ActiveModel::Serializer
  attributes :id, :title_en, :notes, :literals, :label, :description
end
