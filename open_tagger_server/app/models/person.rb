# frozen_string_literal: true

#
# <Description>
#
require 'name_parser'

class Person < ApplicationRecord
  include NetworkException
  include NameParser
  include PgSearch

  attr_accessor :simple_name, :label

  validates_uniqueness_of :viaf_id, allow_blank: true, allow_nil: true
  validates :last, uniqueness: { scope: %i[first middle suffix] }

  belongs_to :gender, optional: true
  has_many :literals  
  belongs_to :entity
 
  before_validation :_parse, :_lookup_attributes, :_set_entity
  after_save :_update_entity

  pg_search_scope :search_by_name, lambda { |query|
    name = NameParser.parse query.unicode_normalize(:nfkc)
    {
      against: [:first, :last],
      query: name[:simple],
      ignoring: :accents,
      using: {
        tsearch: {
          prefix: true,
          any_word: true
        }
      }
    }
  }

  def simple_name
    "#{first} #{middle} #{last}".split.join(' ').delete('[').delete(']')
  end

  def formal_name
    "#{title} #{first} #{middle} #{last} #{suffix}".strip.squish
  end

  def last_first
    "#{last}, #{first} #{middle}"
  end

  def label
    "#{title} #{first} #{middle} #{last} #{suffix}"
  end

  def bio_dates
    "#{yob}-#{yod}"
  end

  def create_from_string(string)
    _parse(string.gsub!(/[^0-9A-Za-z\s]/, ''))
  end

  private

    def _parse(name = self.formal_name)
      puts name
      return if name.nil?
      return unless _chars?(name)
      n = NameParser.parse name.unicode_normalize(:nfkc)
      self.last = n[:last]
      self.first = n[:first]
      self.nick = n[:nickname]
      self.middle = n[:middle]
      self.title = n[:title]
      self.suffix = n[:suffix]
      return self
    end

    def _lookup_attributes
      return if simple_name.nil? && wikidata_id.nil?
      return if simple_name.present? && wikidata_id.present?
      if wikidata_id.present?
        wd = _wikidata_find
        _parse(wd.title)
      else
        return unless _chars?
        wd = _wikidata_search
      end
      return if wd.nil?
      _add_metadata(wd)
    end

    def _wikidata_search
      with_retries(
        rescue_class: [Faraday::TimeoutError, Faraday::ConnectionFailed],
        retry_skip_reason: 'getaddrinfo: Name or service not known'
      ) do
        wd_results = Wikidata::Item.search simple_name
        wd_results.results.take_while  { |result|\
            result.instance_of.first.title == 'human'\
            unless result.instance_of.first.nil?\
          }.first
      end
    end

    def _wikidata_find
      with_retries(
        rescue_class: [Faraday::TimeoutError, Faraday::ConnectionFailed],
        retry_skip_reason: 'getaddrinfo: Name or service not known'
      ) do
        Wikidata::Item.find self.wikidata_id
      end
    end

    def _add_metadata(wd)
      self.yod = wd.date_of_death.date.year if wd.date_of_death.present?
      self.yob = wd.date_of_birth.date.year if wd.date_of_birth.present?
      self.wikidata_id = wd.id if wd.id.present?
      self.image =  wd.image.url if wd.image.present?
      self.gender = Gender.find_or_create_by(title: wd.gender.title)\
        if wd.gender.present?
      _set_authority_ids(wd)
    end

    def _set_entity
      return if self.entity.present?
      self.entity = Entity.create(label: self.formal_name, entity_type: EntityType.find_by(label: 'Person'))
    end

    def _set_authority_ids(wikidata)
      self.viaf_id = _get_authority_id(wikidata.property('P214'))
      self.bnf_id = _get_authority_id(wikidata.property('P268'))
      self.gnd_id = _get_authority_id(wikidata.property('P227'))
      self.isni_id = _get_authority_id(wikidata.property('P213'))
      self.lccn_id = _get_authority_id(wikidata.property('P244'))
      self.olid_id = _get_authority_id(wikidata.property('P648'))
    end

    def _get_authority_id(prop)
      return if prop.nil?
      prop.value
    end

    def _chars?(string = self.simple_name)
      string.chars.any? { |c| ('a'..'z').cover? c.downcase }
    end

    def _update_entity
      self.entity.label = self.simple_name
      self.entity.save
    end
end
