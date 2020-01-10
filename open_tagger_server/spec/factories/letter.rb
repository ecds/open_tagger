# frozen_string_literal: true

# spec/factories/users.rb
FactoryBot.define do
  factory :letter do
    content { Faker::Hipster.paragraphs(number: 2) }
    code { Faker::TvShows::RickAndMorty.character }
    legacy_pk { 999 }
    addressed_to { Faker::Address.street_address }
    addressed_from { Faker::Address.street_address} 
    typed { true }
    signed { true }
    physical_desc { Faker::Movies::Lebowski.quote }
    physical_detail { Faker::Movies::Lebowski.quote }
    physical_notes { Faker::Movies::Lebowski.quote }
    repository_info { Faker::Movies::Lebowski.quote }
    postcard_image { Faker::Movies::Lebowski.quote }
    leaves { 1 }
    sides { 1 }
    postmark { Faker::Movies::Lebowski.quote }
    verified { true }
    envelope { true }
    notes { Faker::Movies::Lebowski.quote }
    recipients { [create(:entity, label: Faker::Movies::Lebowski.character, entity_type: EntityType.find_or_create_by(label: 'person'))] }
    
    transient do
      recipients_count { 2 }
      mentions_count { 6 }
      public_only { true }
    end

    after(:create) do |letter, evaluator|
      if evaluator.public_only
        letter.date = Faker::Date.between(from: DateTime.new(1957), to: DateTime.new(1965, 12).at_end_of_month)
      else
        letter.date = Faker::Date.between(from: DateTime.new(1966), to: Date.today)
      end

      create_list(
        :entity,
        evaluator.recipients_count,
        # entity_type: create(:entity_type, label: 'person'),
        entity_type: EntityType.find_or_create_by(label: 'person'),
        letters_written_to_person: [letter],
        label: Faker::Movies::Lebowski.character
      )

      create(
        :entity,
        # entity_type: create(:entity_type, label: 'place'),
        entity_type: EntityType.find_or_create_by(label: 'place'),
        label: Faker::Movies::HitchhikersGuideToTheGalaxy.location,
        places_sent: [letter]
      )

      create(
        :entity,
        # entity_type: create(:entity_type, label: 'place'),
        entity_type: EntityType.find_or_create_by(label: 'place'),
        label: Faker::Movies::HitchhikersGuideToTheGalaxy.location,
        letters_written_to_place: [letter]
      )

      create(
        :entity,
        # entity_type: create(:entity_type, label: 'place'),
        entity_type: EntityType.find_or_create_by(label: 'person'),
        label: Faker::Movies::HitchhikersGuideToTheGalaxy.location,
        senders: [letter]
      )

      create(
        :letter_publisher,
        letters: [letter]
      )

      # create(
      #   :entity,
      #   # entity_type: create(:entity_type, label: 'place'),
      #   entity_type: EntityType.find_or_create_by(label: 'place'),
      #   label: Faker::Movies::HitchhikersGuideToTheGalaxy.location,
      #   letters_written_to_place: [letter]
      # )

      create_list(
        :entity,
        evaluator.mentions_count,
        # entity_type: create(:entity_type, label: 'organization'),
        entity_type: EntityType.find_or_create_by(label: 'organization'),
        label: Faker::Movies::HitchhikersGuideToTheGalaxy.starship,
        letters: [letter]
      )

      create(
        :repository,
        public: true,
        letters: [letter]
      )
    end
  end
end