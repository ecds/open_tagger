class Repository < ApplicationRecord
  has_many :collections
  has_many :letter_repositories
  has_many :letters, -> { distinct }, through: :letter_repositories

  scope :_public, -> {
    where(public: true)
  }

  def letter_list
    letters.collect(&:id)
  end

  def letter_count
    letters.count
  end
end
