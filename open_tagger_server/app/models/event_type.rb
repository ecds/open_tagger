class EventType < ApplicationRecord
  has_many :entities

  def plural
    title.pluralize
  end
end
