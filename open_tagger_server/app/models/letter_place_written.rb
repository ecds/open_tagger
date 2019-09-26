class LetterPlaceWritten < ApplicationRecord
  belongs_to :entity
  belongs_to :letter
  validates :letter_id, uniqueness: { scope: :entity_id }
end
