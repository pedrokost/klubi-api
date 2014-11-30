require 'rails_helper'

RSpec.describe Api::V1::KlubsController, :type => :controller do

	let!(:klub1) { FactoryGirl.create(:klub) } 
	let!(:klub2) { FactoryGirl.create(:klub) } 
	
	describe 'GET #klubs' do
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
		
		it "does not return klubs that are incomplete" do
			# incomplete: no lat, long and name
		end
	end
end
