class PersonSerializer < ActiveModel::Serializer
  attributes :label, :notes, :literals
end
