# This will guess the User class
FactoryGirl.define do
  factory :obcina do
    name "MyString"
    slug "MyString"
    population_size 1
    geom ""
  end
  factory :statisticna_regija do
    name "MyString"
    slug "MyString"
    population_size 1
    geom ""
  end

  factory :email_stat do
    # last_opened_at "2017-01-14 17:37:33"
    # last_clicked_at "2017-01-14 17:37:33"
    # last_bounced_at "2017-01-14 17:37:33"
    # last_dropped_at "2017-01-14 17:37:33"
    # last_delivered_at "2017-01-14 17:37:33"
  end

  factory :email_stum, :class => 'EmailSta' do
    last_delivery_at "2017-01-14 17:35:02"
  end


  factory :update do
    field 'name'
    oldvalue 'banana'
    newvalue 'pear'
    status 'unverified'
  end


  factory :klub do

    sequence :name do |n|
      "Karate klub #{n}"
    end

		factory :complete_klub do
			latitude 12.25566
			longitude 45.25566
      verified true
      categories ['fitnes']
    end

    factory :klub_branch do
      address 'Trzaska cesta 25, 1000 Ljubljana'
      association :parent, factory: :complete_klub
    end

    factory :complete_klub_branch do
      latitude 12.25566
      longitude 45.25566
      categories ['fitnes']
      verified true
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
