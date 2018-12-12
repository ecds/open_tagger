# frozen_string_literal: true

# spec/factories/users.rb
FactoryBot.define do
  factory :place do
    title { Faker::HitchhikersGuideToTheGalaxy.planet }
    content { Faker::Hipster.paragraph(2, true, 4) }
  end
end