require 'rails_helper'

RSpec.describe Klub, :type => :model do
  
  let!(:klub) { create(:klub, name: 'Karate klub Skocjan') } 

  subject { klub }

  it { should have_db_index(:slug)  } 
  it { should be_valid } # missing name

  it "requires the name" do
  	klub.name = nil
  	expect(klub).not_to be_valid
  end

  it "should generate slug on create" do
  	expect(klub.slug).to eq('karate-klub-skocjan')
  end

  it "should update slug on update" do
  	klub.name = 'Karate Klub Grosuplje'
  	klub.save
  	klub.reload
  	expect(klub.slug).to eq('karate-klub-grosuplje')
  end

  it "should keep slug if not changed" do
  	klub.name = 'Karate Klub Skocjan'
  	klub.save
  	klub.reload
  	expect(klub.slug).to eq('karate-klub-skocjan')
  end

  it "should provide alternative slug if already taken" do
  	expect(klub.persisted?).to be true
  	another_klub = create(:klub, name: klub.name)
  	expect(another_klub.slug).not_to eq(klub.slug)
  	expect(another_klub.slug).not_to be_nil
  	yet_another_klub = create(:klub, name: klub.name)
  	expect(yet_another_klub.slug).not_to eq(klub.slug)
  	expect(yet_another_klub.slug).not_to eq(another_klub.slug)
  end
end
