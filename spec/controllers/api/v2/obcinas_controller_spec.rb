require 'rails_helper'

require 'pry'

RSpec.describe Api::V2::ObcinasController, type: :controller do

  describe 'GET #obcinas' do
    let!(:touching_obcina) { FactoryGirl.create(:obcina, name: 'Touching obcina', slug: 'touching-obcina' ) }
    let!(:obcina) { FactoryGirl.create(:obcina, name: 'Grosuplje', slug: 'grosuplje' ) }
    let!(:klub) { FactoryGirl.create(:complete_klub, latitude: 20.1, longitude: 10.1, categories: ['fitnes']) }

    describe "without providing category param" do
      before do
        allow_any_instance_of(Obcina).to receive(:category_klubs).and_return([klub])
        get :show, params: { id: obcina.url_slug, category: nil }
      end

      it "should not throw an error" do
        expect { response }.not_to raise_error
      end

      it "should return list of all klubs in the obcina" do
        obcina = json_response[:data]

        expect(obcina[:relationships][:klubs][:data]).to be_a(Array)
        expect(obcina[:relationships][:klubs][:data].length).to eq 1
      end
    end

    describe "?category=fitnes" do
      subject { response }

      it "should return a valid obcina response" do
        get :show, params: { id: obcina.url_slug, category: 'fitnes' }
        expect(response.status).to eq 200
        expect(response).to match_response_schema("v2/obcina")
      end

      it "should use the url_slug as id" do
        get :show, params: { id: obcina.url_slug, category: 'fitnes' }

        expect(json_response[:data][:id]).to eq obcina.url_slug
      end

      it "should include a list of ids of klubs in the obcina" do
        allow_any_instance_of(Obcina).to receive(:category_klubs).and_return([klub])
        get :show, params: { id: obcina.url_slug, category: 'fitnes' }
        obcina = json_response[:data]

        expect(obcina[:relationships][:klubs][:data]).to be_a(Array)
        expect(obcina[:relationships][:klubs][:data].length).to eq 1
        expect(obcina[:relationships][:klubs][:data][0][:type]).to eq "klubs"
      end

      it "should include short klubs objects" do
        allow_any_instance_of(Obcina).to receive(:category_klubs).and_return([klub])
        get :show, params: { id: obcina.url_slug, category: 'fitnes' }
        returned_klub = json_response[:included].first

        # Be simple
        expect(returned_klub[:id]).to eq klub.url_slug

        # Not complex
        expect(returned_klub[:attributes].keys).not_to include :phone
      end

      it "should call obcina.category_klubs" do
        # AMS seems to call it twice, once for the klub_ids, once for the `include`.
        expect_any_instance_of(Obcina).to receive(:category_klubs).with('gimnastika').at_least(:once)
        get :show, params: { id: obcina.url_slug, category: 'gimnastika' }
      end

      it "should include a link to nearby obcinas" do
        expect_any_instance_of(Obcina).to receive(:neighbouring_obcinas).at_least(:once).and_return([touching_obcina])
        get :show, params: { id: obcina.url_slug, category: 'fitnes' }

        expect(json_response[:data][:relationships][:"neighbouring-obcinas"][:data].length).to eq 1
        expect(json_response[:data][:relationships][:"neighbouring-obcinas"][:data][0][:id]).to eq touching_obcina.url_slug
      end

      it "should include flat nearby obcina objects" do
        expect_any_instance_of(Obcina).to receive(:neighbouring_obcinas).at_least(:once).and_return([touching_obcina])
        get :show, params: { id: obcina.url_slug, category: 'fitnes' }

        neighbouring_obcinas = json_response[:included].first

        # Be simple
        expect(neighbouring_obcinas[:id]).to eq touching_obcina.url_slug
        expect(neighbouring_obcinas[:attributes][:name]).to eq touching_obcina.name

        # Not complex
        expect(neighbouring_obcinas[:attributes].keys).not_to include :geom
        expect(neighbouring_obcinas[:attributes].keys).not_to include :neighbouring_obcinas
      end
    end
  end
end
