class LetterRecipent < ApplicationRecord
  belongs_to :letter
  belongs_to :entity
end
