class LetterPlaceWritten < ApplicationRecord
  belongs_to :entity
  belongs_to :letter
end
