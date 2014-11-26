# This will guess the User class
FactoryGirl.define do
  factory :klub do
    sequence :name do |n|
      "Karate klub #{n}"
    end
  end
end