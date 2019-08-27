class LetterWithContentSerializer < ActiveModel::Serializer
  belongs_to :recipient
  attributes :id, :date, :code, :recipient_list, :legacy_pk, :content
end
