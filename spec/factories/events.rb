FactoryBot.define do
  factory :event do
    sequence(:external_id) { |n| "ext_#{n}" }
    title       { Faker::Music::RockBand.name + " Concert" }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    start_date  { Faker::Date.forward(days: 10) }
    end_date    { Faker::Date.forward(days: 15) }
    image_url   { Faker::Internet.url(host: "example.com", path: "/image.jpg") }
    event_url   { Faker::Internet.url }
  end
end
