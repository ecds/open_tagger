class LiteralSerializer < ActiveModel::Serializer
  belongs_to :entity
  attributes :text, :unassigned, :entity_type, :review
end
