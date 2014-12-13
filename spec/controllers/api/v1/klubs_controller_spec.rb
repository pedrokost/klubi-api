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

  describe 'POST #import' do

    before do
      @request.headers['Content-Type'] = 'application/vng.zatresi.v1+json'
      @request.headers['Accept'] = 'application/vng.zatresi.v1+json'
      @request.headers['Referer'] = 'http://import.zatresi.si'
    end
    let(:payload) do
      # valid_attrs = [:name, :address, :website, :phone, :email]
      # TODO: Later add facebook
      attributes_for(:klub_to_import)
    end

    # curl -X POST -H "Content-Type: application/json" -H "Referer: http://import.zatresi.si" -H "Accept: application/json" -d '{"klub": {"name": "boltzmann"}}' http://api.app.local:3000/klubs/import

    context "incorrect referrer" do
      before do
        @request.headers['Referer'] = ''
      end

      it "should reject payload if headers not complete" do

        post :import, klub: payload
        expect(response.status).to eq 403
      end
    end

    describe "creating resources" do
      it "should create a klub" do
        # puts JSON.pretty_generate(payload)
        expect {
          post :import, klub: payload
        }.to change{ Klub.unscoped.count }
      end

      it "should respond 201" do
        post :import, klub: payload
        expect(response.status).to eq 201
      end

      # it "should include a Location header identifying the location of created klubs"

      context "invalid klub" do

        it "should return 422" do
          payload[:name] = nil
          post :import, klub: payload
          expect(response.status).to eq 422
        end
      end
    end

    describe "updating resources" do

      before do
        create(:klub, name: "Pedro")
        payload[:name] = "Pedro"
      end

      it "should simply reject resources that have the same name than any other existing" do
        expect {
          post :import, klub: payload
        }.not_to change{ Klub.unscoped.count }
      end

      it "should return 409 Conflict" do
        post :import, klub: payload
        expect(response.status).to eq 409

      end
    end
  end
end
