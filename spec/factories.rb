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

    factory :klub_branch do
      association :parent, factory: :complete_klub
    end

    factory :complete_klub_branch do
      latitude 12.25566
      longitude 45.25566
      association :parent, factory: :complete_klub
    end


    factory :klub_to_import do
      address 'Trzaska cesta 25, 1000 Ljubljana'
      email 'klub@email.com'
      phone '041 563 521'
      website 'http://petelin.si'
    end
  end
end
