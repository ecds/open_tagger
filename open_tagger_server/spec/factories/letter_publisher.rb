# frozen_string_literal: true

# spec/factories/users.rb
FactoryBot.define do
  factory :letter_publisher do
    label { Faker::TvShows::RickAndMorty.character }
  end
end