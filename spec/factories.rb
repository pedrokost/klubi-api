# This will guess the User class
FactoryGirl.define do
  factory :klub do
    sequence :name do |n|
      "Karate klub #{n}"
    end
		factory :complete_klub do
			latitude 12.25566
			longitude 45.25566
		end
  end
end