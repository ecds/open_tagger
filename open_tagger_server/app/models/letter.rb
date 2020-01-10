# frozen_string_literal: true

#
# <Description>
#
class Letter < ApplicationRecord
  include PgSearch::Model
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  acts_as_taggable

  before_save :flag_letter

  has_many :letter_repositories
  has_many :repositories, through: :letter_repositories

  has_many :mentions
  has_many :entities_mentioned, through: :mentions, source: :entity

  has_many :letter_recipients
  has_many :recipients, through: :letter_recipients, source: :entity

  has_many :letter_senders
  has_many :senders, through: :letter_senders, source: :entity

  has_many :letter_place_written
  has_many :places_written, through: :letter_place_written, source: :entity

  has_many :letter_place_sent
  has_many :places_sent, through: :letter_place_sent, source: :entity

  has_many :letter_collections
  has_many :collections, through: :letter_collections

  belongs_to :letter_owner, optional: true
  belongs_to :file_folder, optional: true
  belongs_to :letter_publisher, optional: true
  belongs_to :owner_rights, optional: true
  belongs_to :language, optional: true
  # belongs_to :place_entity_sent, optional: true, class_name: 'Entity'

  index_name Rails.application.class.parent_name.underscore
  document_type self.name.downcase
  
  scope :between, lambda { |start, _end|
    where('date >= ? AND date <= ?', start, _end)
  }

  scope :recipients, lambda { |recipent|
    joins(:recipients)
    .where('entities.label = ?', recipent)
  }

  scope :repositories, lambda { |repository|
    joins(:repositories)
    .where('repositories.label = ?', repository)
  }

  scope :_public, -> {
    includes(:repositories)
    .references(:repositories)
    .where(
      repositories: {
        public: true
      }
    )
      .where('letters.date BETWEEN ? AND ?', DateTime.new(1957), DateTime.new(1965, 12).at_end_of_month)
  }

  scope :flagged, -> {
    where(flagged: true)
  }

  pg_search_scope :search_by_relations,
                  against: :content,
                  associated_against: {
                    entities_mentioned: :label,
                    recipients: :label,
                    places_sent: :label,
                    places_written: :label
                  },
                  ignoring: :accents,
                  using: {
                    tsearch: {
                      prefix: true,
                      any_word: true
                    }
                  }

  def formatted_date
    if date
      date.strftime("%d %B %Y")
    else
      none
    end
  end

  def recipient_list
    if self.recipients.present?
      recipients.collect(&:label).join(', ')
    end
  end

  def entities_mentioned_list
    list = {}
    EntityType.all.each do |et|
      list[et.label] = []
      entities_mentioned.by_type(et.label).each { |e| list[et.label].push(e)}
    end
    list
    # entities_mentioned.collect(&:label).join(', ')
  end

  def entity_count
    entities_mentioned.count
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

    def flag_letter
      doc = Nokogiri::XML(content)
      EntityType.all.each do |type|
        next if doc.xpath("//#{type.label}").empty?
        doc.xpath("//#{type.label}").each do |tag|
          if tag['class'] && tag['class'].include?('flagged')
            self.flagged = true
          end
        end
      end
    end

    def public_letter_start
      DateTime.new(1957)
    end

    def public_letter_end
      DateTime.new(1965, 12).at_end_of_month
    end
end
