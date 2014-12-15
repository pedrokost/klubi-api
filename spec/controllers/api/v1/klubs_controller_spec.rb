require 'rails_helper'

require 'json'

RSpec.describe Api::V1::KlubsController, :type => :controller do


  describe 'GET #klubs' do
    let!(:klub1) { FactoryGirl.create(:klub, latitude: 20.1, longitude: 10.1) }
    let!(:klub2) { FactoryGirl.create(:klub, latitude: 20.1, longitude: 10.1) }

    before do
      get :index
    end
    subject { response }

    it { should be_success }

    it "should return all items" do
      klubs = JSON.parse(response.body)['klubs']
      expect(klubs.length).to eq 2
    end

    it "should return a list of klubs" do
      expect(response.status).to eq 200
      expect(response).to match_response_schema("klubs")
    end

    describe "very incomplete data" do
      before do
        klub1.latitude = nil;
        klub1.longitude = nil;
        klub1.save

        get :index
      end

      it "does not return klubs that are incomplete" do
        # incomplete: no lat, long and name
        klubs = JSON.parse(response.body)['klubs']
        expect(klubs.length).to eq 1
      end
    end
  end

end
