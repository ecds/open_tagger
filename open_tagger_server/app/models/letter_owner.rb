# frozen_string_literal: true

#
# <Description>
#
class LetterOwner < ApplicationRecord
  has_many :letters
end
