# frozen_string_literal: true

class WithUuid < ApplicationRecord
  self.abstract_class = true

  before_create :set_uuid

  def set_uuid
    self.id = SecureRandom.uuid
  end
end
