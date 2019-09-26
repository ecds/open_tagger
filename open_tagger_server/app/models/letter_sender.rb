# frozen_string_literal: true

class LetterSender < ApplicationRecord
  belongs_to :letter
  belongs_to :entity
end
