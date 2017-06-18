require 'rails_helper'

require 'pry'

RSpec.describe Api::V2::ObcinasController, type: :controller do

  describe 'GET #obcinas' do
    let!(:obcina) { FactoryGirl.create(:obcina, name: 'Grosuplje', slug: 'grosuplje' ) }
    let!(:klub) { FactoryGirl.create(:complete_klub, latitude: 20.1, longitude: 10.1, categories: ['fitnes']) }

    describe "without providing category param" do
      it "should raise exception" do
        expect { get :show, id: obcina.url_slug, category: nil }.to raise_error(ActionController::ParameterMissing)
      end
    end

    describe "?category=fitnes" do
      subject { response }

      it "should return a valid obcina response" do
        get :show, id: obcina.url_slug, category: 'fitnes'
        expect(response.status).to eq 200
        expect(response).to match_response_schema("v2/obcina")
      end

      it "should use the url_slug as id" do
        get :show, id: obcina.url_slug, category: 'fitnes'

        expect(json_response[:data][:id]).to eq obcina.url_slug
      end

      it "should include a list of ids of klubs in the obcina" do
        allow_any_instance_of(Obcina).to receive(:category_klubs).and_return([klub])
        get :show, id: obcina.url_slug, category: 'fitnes'
        obcina = json_response[:data]

        expect(obcina[:relationships][:klubs][:data]).to be_a(Array)
        expect(obcina[:relationships][:klubs][:data].length).to eq 1
        expect(obcina[:relationships][:klubs][:data][0][:type]).to eq "klubs"
      end

      it "should include short klubs objects" do
        allow_any_instance_of(Obcina).to receive(:category_klubs).and_return([klub])
        get :show, id: obcina.url_slug, category: 'fitnes'
        returned_klub = json_response[:included].first

        # Be simple
        expect(returned_klub[:id]).to eq klub.url_slug

        # Not complex
        expect(returned_klub[:attributes].keys).not_to include :phone
      end

      it "should call obcina.category_klubs" do
        # AMS seems to call it twice, once for the klub_ids, once for the `include`.
        expect_any_instance_of(Obcina).to receive(:category_klubs).with('gimnastika').at_least(:once)
        get :show, id: obcina.url_slug, category: 'gimnastika'
      end
    end
  end
end
