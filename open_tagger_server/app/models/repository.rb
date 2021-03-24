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
    public_letters = letters._public.map { |letter| {
    id: letter.id,
    date: letter.formatted_date,
    date_stamp: letter.date,
    sort_name: get_sort_name(letter.recipients),
    recipients: letter.recipients.map { |r| {
      id: r.id,
      name: r.label
      }}
    }}
    return public_letters if public_letters.empty?

    public_letters.each do |letter|
      if letter[:recipients].empty?
        letter[:recipients].push({ name: 'unknown' })
      end
    end
    public_letters = public_letters.sort_by { |l| l[:date_stamp] }
    public_letters.sort_by { |l| l[:sort_name] }
  end

  def letter_count
    "Total Beckett Letters: #{letters.count}; letters listed below from 1957-1965."
  end

  private

  def get_sort_name(recipients)
    return 'unknown' if recipients.empty?

    "#{recipients.first.label.split(' ').last}, #{recipients.first.label.split(' ').first}"
  end
end
