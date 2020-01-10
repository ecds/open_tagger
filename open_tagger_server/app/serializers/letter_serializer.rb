class LetterSerializer < ActiveModel::Serializer
  # belongs_to :recipient
  has_many :recipients
  has_many :repositories
  has_many :places_written
  has_many :entities_mentioned
  belongs_to :letter_owner
  belongs_to :letter_publisher
  attributes :id, :date, :code, :recipient_list, :legacy_pk, :addressed_to,
  :addressed_to,
  :addressed_from,
  :typed,
  :signed,
  :physical_desc,
  :physical_detail,
  :physical_notes,
  :repository_info,
  :postcard_image,
  :leaves,
  :sides,
  :postmark,
  :verified,
  :envelope,
  :notes,
  :entity_count,
  :recipients,
  :entities_mentioned_list,
  :letter_publisher,
  :formatted_date,
  :tag_list
end
