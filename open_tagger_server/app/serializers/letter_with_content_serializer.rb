class LetterWithContentSerializer < ActiveModel::Serializer
  has_many :entities_mentioned
  attributes :id, :date, :recipient_list, :legacy_pk, :content, :entities_mentioned_list, :formatted_date
end
