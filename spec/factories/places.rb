FactoryBot.define do
  factory :place do
    name { "MyString" }
    address { "MyString" }
    latitude { 1.5 }
    longitude { 1.5 }
    place_id { "MyString" }
    type { "" }
    global_code { "MyString" }
    compound_code { "MyString" }
    url { "MyString" }
    memo { "MyText" }
  end
end
