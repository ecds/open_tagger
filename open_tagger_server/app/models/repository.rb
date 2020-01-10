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

  def public_letters_hash
    letters._public.map { |letter| {
      id: letter.id,
      date: letter.formatted_date,
      recipients: letter.recipients.map { |r| {
        id: r.id,
        name: r.label
      }}
    }}
  end

  def letter_count
    letters.count
  end
end
