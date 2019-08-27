class LetterSerializer < ActiveModel::Serializer
  belongs_to :recipient
  attributes :id, :date, :code, :recipient_list, :legacy_pk, :addressed_to,
  :addressed_to,
  :addressed_from,
  :destination,
  :recipient,
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
  :notes
end
