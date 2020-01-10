require "rails_helper"

RSpec.describe Letter, type: :model do

  before { create_list(:letter, 5) }
  before { create_list(:letter, public_only: false, 5) }
  
  context 'generic letters' do
    it 'has a string list of recipients that are peoplee' do
      Letter.all.each do |letter|
        letter.recipient_list.split(',').each do |r|
          person = Entity.by_type('person').find_by(label: r.strip)
          expect(person).not_to eq(nil)
        end
      end
    end

    it 'has a string list of recipients that are not something other than people' do
      types = EntityType.all.collect(&:label)
      types.delete_at(types.index('person'))
      Letter.all.each do |letter|
        letter.recipient_list.split(',').each do |r|
          person = Entity.by_type(types.sample).find_by(label: r.strip)
          expect(person).to eq(nil)
        end
      end
    end

    it 'has a dated formatted_date in the european style' do
      letter = Letter.first
      letter.date = DateTime.now
      expect(letter.formatted_date).to eq(DateTime.now.strftime("%d %B %Y"))
    end
  end

  it 'has a hash where every entity type is a key' do
    EntityType.all.each do |et|
      expect(Letter.last.entities_mentioned_list).to have_key(et.label)
    end
  end

  it 'has a hash where every value is an array' do
    Letter.second.entities_mentioned_list.each do |key, value|
      expect(value).to be_kind_of(Array)
    end
  end

  it 'has entities mentioned under the correct key' do
    Letter.first.entities_mentioned_list.each do |key, value|
      if value.length > 0
        value.each do |e|
          expect(e.entity_type.label).to eq(key)
        end
      end
    end
  end

  it 'has an entity_count of type Integer' do
    expect(Letter.last.entity_count).to be_kind_of(Integer)
  end

  it 'flags letter on save when content includes an element with the flagged class' do
    letter = Letter.second
    letter.content = '<person class="flagged">foo</person>'
    letter.save
    expect(Letter.second.flagged).to eq(true)
  end

  it 'returns letters by recipient' do
    person = Entity.by_type('person').first
    Letter.recipients(person.label).each do |letter|
      expect(letter.recipient_list).to include(person.label)
    end
  end

  it 'does not find letters for person who is not a recipient' do
    person = create(
      :entity,
      label: Faker::TvShows::RickAndMorty.character,
      entity_type: EntityType.find_by(label: 'person')
    )
    expect(Letter.recipients(person.label)).to be_empty
  end

  it 'only returns leters dated on or after start date' do
    letters = Letter.between(DateTime.new(1957), DateTime.new(1965, 12).at_end_of_month)
    # p letters.minimum('date')
    expect(letters.minimum('date')).to be >= DateTime.new(1957)
  end

  it 'only returns leters dated on or before end date' do
    letters = Letter.between(DateTime.new(1957), DateTime.new(1965))
    p letters.maximum('date')
    expect(letters.maximum('date')).to be <= DateTime.new(1966)
  end
end
