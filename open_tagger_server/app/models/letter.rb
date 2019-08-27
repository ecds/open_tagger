# frozen_string_literal: true

#
# <Description>
#
class Letter < ApplicationRecord
  has_many :letter_repositories
  has_many :repositories, through: :letter_repositories

  has_many :mentions
  has_many :entities, through: :mentions

  has_many :letter_place_written
  has_many :places_written, through: :letter_place_written, source: :entity

  belongs_to :recipient, class_name: 'Entity', foreign_key: :recipient
  # belongs_to :destination, class_name: 'Entity', foreign_key: :destination

  belongs_to :letter_owner, optional: true
  belongs_to :file_folder, optional: true
  belongs_to :letter_publisher, optional: true

  # belongs_to :sent_from, class_name: 'Literal', foreign_key: 'sent_from_actual_id', optional: true
  # belongs_to :sent_from_second, class_name: 'Entity', foreign_key: 'sent_from_second_id', optional: true
  # belongs_to :sender, class_name: 'Entity', foreign_key: 'sender_id', optional: true
  # belongs_to :recipient, class_name: 'Entity', foreign_key: 'recipient_id', optional: true
  # belongs_to :owner, class_name: 'Person', foreign_key: 'owner_rights_id', optional: true
  # belongs_to :language, optional: true
  # belongs_to :file_folder, optional: true
  # belongs_to :letter_publisher, optional: true
  # belongs_to :owner, optional: true

  # validates :code, uniqueness: true
  # validates_associated :sender
  # validates_associated :recipients

  # before_validation :set_code

  scope :between, lambda { |start, _end|
    where('date BETWEEN ? AND ?', start, _end)
  }

  scope :recipients, lambda { |recipent|
    joins(:recipient)
    .where('entities.label = ?', recipent)
  }

  scope :repositories, lambda { |repository|
    joins(:repositories)
    .where('repositories.label = ?', repository)
  }

  def recipient_list
    # if self.recipients.present?
    #   ActionView::Base.full_sanitizer.sanitize(recipients.collect(&:label).join(', '))
    # end
  end

  def entities_mentioned
    literals.collect(&:entity).collect(&:label).join(', ')
  end

  private

    #
    # <Description>
    #
    # @return [<String>] <description>
    # SABE 01-09-64 KABO
    #
    def set_code
      return if code.present?
      self.code = "#{sender.label.split(' ').first[0..1].upcase}#{sender.label.split(' ').last[0..1].upcase} #{date.strftime('%d-%m-%y')} #{recipients.first.label.split(' ').first[0..1].upcase}#{recipients.first.label.split(' ')[-1][0..1].upcase}"
    end
end
