class LetterRepository < ApplicationRecord
  belongs_to :letter
  belongs_to :repository
end
