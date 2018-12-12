class LetterSerializer < ActiveModel::Serializer
  # has_many :repositories
  # has_many :recipents
  # belongs_to :sent_to
  # belongs_to :sent_from
  # belongs_to :country
  # belongs_to :city
  # belongs_to :location
  # belongs_to :letter_type
  # belongs_to :sender
  # belongs_to :recipent
  # belongs_to :owner
  # belongs_to :language
  # belongs_to :place_literal
  attributes :id, :content, :date_sent, :letter_code
end
