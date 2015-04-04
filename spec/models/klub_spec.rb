require 'rails_helper'
require 'pry'

RSpec.describe Klub, :type => :model do

  let!(:klub) { create(:klub, name: 'Karate klub Skocjan -- ') }

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

  it "should create valid slug when appending strings" do
    expect(klub.slug).to eq('karate-klub-skocjan')

    expect(Randgen).to receive(:last_name).and_return('2')

    another_klub = create(:klub, name: klub.name)
  	expect(another_klub.slug).to eq('karate-klub-skocjan-2')
    expect(another_klub.slug).not_to eq('karate-klub-skocjan 2')
  end

  it "should make sure there is no space characters in the slug" do
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


  describe "geocoding" do

    Geocoder::Lookup::Test.add_stub(
      "Trzaska 25, 1000 Ljubljana", [
        {
          'latitude'          => 46.0448994,
          'longitude'         => 14.4892307,
          'address'           => 'Univerza v Ljubljani, Tržaška cesta 25, 1000 Ljubljana, Slovenija',
          'city'              => 'Ljubljana',
          'formatted_address' => 'Univerza v Ljubljani, Tržaška cesta 25, 1000 Ljubljana, Slovenija'
        }
      ]
    )

    context "on create" do

      describe "address provided" do
        let(:klub) { build(:klub, address: "Trzaska 25, 1000 Ljubljana") }

        it "should compute latlong" do
          klub.save
          expect(klub.reload.latitude).not_to be_nil
          expect(klub.reload.longitude).not_to be_nil
          expect(klub.reload.town).not_to be_nil

          expect(klub.reload.latitude).to eq 46.044899
          expect(klub.reload.longitude).to eq 14.489231
          expect(klub.reload.town).to eq 'Ljubljana'
        end

        it "should prettify the address" do
          klub.save
          expect(klub.reload.address).to eq "Univerza v Ljubljani, Tržaška cesta 25, 1000 Ljubljana, Slovenija"
        end

        it "should fillin the town" do
          klub.save
          expect(klub.reload.town).to eq 'Ljubljana'
        end

        it "should not run if lat, long, address and town provided as well" do
          klub.latitude = 20
          klub.longitude = 35
          klub.town = 'Lj'
          klub.save

          expect(klub.reload.latitude).to eq 20
          expect(klub.reload.longitude).to eq 35
          expect(klub.reload.town).to eq 'Lj'
        end
      end

      describe "address not provided" do
        before do
          klub = create(:klub, address: "")
        end
        it "shoud not run if no address" do
          # TODO: assert geocoder not run
          expect(klub.latitude).to be_nil
          expect(klub.longitude).to be_nil
          expect(klub.town).to be_nil
        end
      end
    end

    context "on save" do
      let(:klub) { create(:klub, address: "Trzaska 25, 1000 Ljubljana") }
      it "should not run" do
        expect(klub.latitude).to eq 46.0448994
        expect(klub.longitude).to eq 14.4892307

        klub.address = "Vrazov trg 2, 1104 Ljubljana, Slovenija"
        klub.save

        expect(klub.latitude).to eq 46.0448994
        expect(klub.longitude).to eq 14.4892307
      end
    end
  end
end
