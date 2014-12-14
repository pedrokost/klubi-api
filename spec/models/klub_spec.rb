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

  it "should eliminate special characters when creating the slug" do
    klub.name = "Škocjanski kareški Karate Črni klub"
    klub.save
    expect(klub.reload.slug).to eq 'skocjanski-kareski-karate-crni-klub'
  end

  it "should eliminate special characters from the slug" do
    klub.name = "Škocjansk!!i kareš~ki   "
    klub.save
    expect(klub.reload.slug).to eq 'skocjansk-i-kares-ki'
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

  # TODO: This slug it incocerrect: it leafes first lette capisalized and sumiki
  # Športno rekreativni center Spartacus

  it "should provide alternative slug if already taken" do
  	expect(klub.persisted?).to be true
  	another_klub = create(:klub, name: klub.name)
  	expect(another_klub.slug).not_to eq(klub.slug)
  	expect(another_klub.slug).not_to be_nil
  	yet_another_klub = create(:klub, name: klub.name)
  	expect(yet_another_klub.slug).not_to eq(klub.slug)
  	expect(yet_another_klub.slug).not_to eq(another_klub.slug)
  end

  describe "complete scope" do
    let!(:klub2) { create(:complete_klub) }

    it "Klub.all should return only completed models by default" do
      expect(Klub.all).to eq([klub2])
      expect(Klub.unscoped).to eq([klub, klub2])
    end
  end

  it "should be complete if name, latitude and longitude are given" do
    expect(klub.complete?).to be false
    klub.latitude = 12
    klub.longitude = 45
    klub.save
    expect(klub.complete?).to be true
  end

  it "should update complete attribute when saving" do
    klub.latitude = 12
    klub.longitude = 45
    klub.save

    expect(klub.complete?).to be true
  end

end
