class Repository < ApplicationRecord
  has_many :collections
  has_many :letter_repositories
  has_many :letters, through: :letter_repositories
end
