# frozen_string_literal: true

#
# <Description>
#
class Letter < ApplicationRecord
  has_many :letter_repositories
  has_many :respositories, through: :letter_repositories

  has_many :letter_recipients
  has_many :recipients, through: :letter_recipients, source: :entity

  has_many :letter_entities
  has_many :entities, through: :letter_entities

  belongs_to :sent_to, class_name: 'LocationLiteral', foreign_key: 'sent_to_actual_id', optional: true
  belongs_to :sent_from, class_name: 'LocationLiteral', foreign_key: 'sent_from_actual_id', optional: true
  belongs_to :country, class_name: 'Place', foreign_key: 'country_id', optional: true
  belongs_to :city, class_name: 'Place', foreign_key: 'city_id', optional: true
  belongs_to :location, optional: true
  belongs_to :letter_type, optional: true
  belongs_to :sender, class_name: 'Entity', foreign_key: 'sender_id', optional: true
  # belongs_to :recipient, class_name: 'Entity', foreign_key: 'recipient_id', optional: true
  # belongs_to :owner, class_name: 'Person', foreign_key: 'owner_rights_id', optional: true
  belongs_to :language, optional: true
  belongs_to :place_literal, optional: true

  validates :letter_code, uniqueness: true
  validates_associated :sender
  validates_associated :recipients

  before_validation :set_letter_code

  def recipient_list
    if recipients.present?
      ActionView::Base.full_sanitizer.sanitize(recipients.collect(&:label).join(', '))
    end
  end

  private

    #
    # <Description>
    #
    # @return [<String>] <description>
    # SABE 01-09-64 KABO
    #
    def set_letter_code
      return if letter_code.present?
      self.letter_code = "#{sender.label.split(' ').first[0..1].upcase}#{sender.label.split(' ').last[0..1].upcase} #{date_sent.strftime('%d-%m-%y')} #{recipients.first.label.split(' ').first[0..1].upcase}#{recipients.first.label.split(' ')[-1][0..1].upcase}"
    end
end
