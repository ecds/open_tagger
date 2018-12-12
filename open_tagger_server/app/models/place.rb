# frozen_string_literal: true

#
# <Description>
#
class Place < ApplicationRecord
  include NetworkException
  include PgSearch

  has_many :admin_areas
  has_many :sub_places, through: :admin_areas, source: :sub_place

  has_many :admins, class_name: 'AdminArea', foreign_key: :sub_place_id
  has_many :admin_places, through: :admins, source: :place

  has_many :addresses

  has_many :literals

  validates_uniqueness_of :wikidata_id, allow_nil: true, allow_blank: true

  before_validation :_lookup, :_add_metadata
  before_save :_add_metadata
  # after_save :_create_sub_areas

  attr_accessor :wikidata

  pg_search_scope :search_by_title, lambda { |query|
    {
      against: [:title_en, :native_label],
      query: query,
      ignoring: :accents,
      using: {
        tsearch: {
          prefix: true,
          any_word: true
        }
      }
    }
  }

  def label
    title_en
  end

  def description
    notes
  end

  private

    def _lookup_wd
      return if title_en.nil?
      return if wikidata_id.present?
      puts "looking up #{title_en}"
      # with_retries(
      #   rescue_class: [Faraday::TimeoutError, Faraday::ConnectionFailed],
      #   retry_skip_reason: 'getaddrinfo: Name or service not known'
      # ) do
      r = Wikidata::Item.search title_en; nil
      return if r.results.first.nil?
      r.results.each do |e|
        e.instance_of.each do |i|
          return e if i.title.starts_with? 'country within'
          return e if i.title.equal? 'country'
        end
      end
      r.results.first
    end

    def _lookup
      wikidata = _lookup_wd
      self.wikidata_id = wikidata.id if wikidata.present?
    end

    def _add_metadata
      return if self.wikidata_id.nil?
      with_retries(
        rescue_class: [Faraday::TimeoutError, Faraday::ConnectionFailed],
        retry_skip_reason: 'getaddrinfo: Name or service not known'
      ) do
        wd = Wikidata::Item.find self.wikidata_id
        return if wd.nil?
        self.wikidata = wd
        # return unless wd.instance_of.collect(&:title).include?('sovereign state' || 'historical country')
        self.title_en = wd.labels['en'].value if wd.labels['en'].present?
        self.native_label = wd.property('P1705').text if wd.property('P1705').present?
        self.iso_code = wd.property('P297').value if wd.property('P297').present?
        self.viaf_id = wd.property('P214').value if wd.property('P214').present?
        self.geonames_id = wd.property('P1566').value if wd.property('P1566').present?
        self.wikidata_id = wd.id if wd.id.present?
        self.start_year = wd.property('P571').date.year if wd.property('P571').present?
        self.end_year = wd.property('P576').date.year if wd.property('P576').present?
      end
    end

    def _create_sub_areas
      return if wikidata_id.nil?
      with_retries(
        rescue_class: [Faraday::TimeoutError, Faraday::ConnectionFailed],
        retry_skip_reason: 'getaddrinfo: Name or service not known'
      ) do
        self.wikidata = Wikidata::Item.find wikidata_id
        self.wikidata.properties('P150').collect(&:id).each do |sub_id|
          # next if Place.find_by(wikidata_id: sub_place)
          pl = Place.find_or_create_by(wikidata_id: sub_id)
          next if self.admin_places.collect(&:wikidata_id).include? sub_id
          next if AdminArea.find_by(place: self, sub_place: pl).present?
          puts "Adding #{pl.title_en} to #{self.title_en} (#{pl.wikidata_id} - #{self.wikidata_id})"
          pl.admin_places << self
          pl.save
        end
      end
    end
end
