class LetterRecipient < ApplicationRecord
  belongs_to :letter
  belongs_to :entity
  validates :letter_id, uniqueness: { scope: :entity_id }
end
