require 'rails_helper'

RSpec.describe Api::V2::OnlineTrainingEntriesController, type: :controller do

  describe 'GET #online_training_entries/:id' do
    # describe "without providing category param" do
    #   before do
    #     allow_any_instance_of(Obcina).to receive(:category_klubs).and_return([klub])
    #     get :show, params: { id: obcina.url_slug, category: nil }
    #   end

    #   it "should not throw an error" do
    #     expect { response }.not_to raise_error
    #   end

    #   it "should return list of all klubs in the obcina" do
    #     obcina = json_response[:data]

    #     expect(obcina[:relationships][:klubs][:data]).to be_a(Array)
    #     expect(obcina[:relationships][:klubs][:data].length).to eq 1
    #   end
    # end
  end


  describe 'GET #online_training_entries' do
    let!(:entry_1) { FactoryBot.create(:online_training_entry, title: 'Entry 1', slug: 'entry-1' ) }
    let!(:entry_2) { FactoryBot.create(:online_training_entry, title: 'Entry 2', slug: 'entry-2' ) }
    let!(:terminated_entry) { FactoryBot.create(:online_training_entry, terminated_at: Date.today ) }
    let!(:unvefiried_entry) { FactoryBot.create(:online_training_entry, is_verified: false ) }

    describe "without providing category param" do

      before do
        get :index
      end

      subject { response }

      it { should be_successful }


      it "should return all verified online training entries" do
        online_training_entries = json_response[:data]
        expect(online_training_entries.length).to eq 2
      end

       it "should not return terminated online training entries" do
        entry_ids = json_response[:data].map{ |entry| entry[:id] }
        expect(entry_ids).not_to include terminated_entry.url_slug
      end

      it "should not return unverified online training entries" do
        entry_ids = json_response[:data].map{ |entry| entry[:id] }
        expect(entry_ids).not_to include unvefiried_entry.url_slug
      end

      it "should match the schema" do
        p response.body
        expect(response).to match_response_schema("v2/online_training_entries")
      end
    end
  end
end
