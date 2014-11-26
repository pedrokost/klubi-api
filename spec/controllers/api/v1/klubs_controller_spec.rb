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

		it "should be namespaced under klubs" do
			body = JSON.parse(response.body)
			expect(body).to include('klubs')
		end

		it "should return all items" do
			klubs = JSON.parse(response.body)['klubs']
			expect(klubs.length).to eq 2
		end

		it "should return a list of klubs" do
			klubs = JSON.parse(response.body)['klubs']

			expect( klubs.all? { |g| g.key?('id') } ).to be true
			expect( klubs.all? { |g| g.key?('name') } ).to be true
			expect( klubs.all? { |g| g.key?('slug') } ).to be true
			expect( klubs.all? { |g| g.key?('address') } ).to be true
			expect( klubs.all? { |g| g.key?('town') } ).to be true
			expect( klubs.all? { |g| g.key?('website') } ).to be true
			expect( klubs.all? { |g| g.key?('phone') } ).to be true
			expect( klubs.all? { |g| g.key?('email') } ).to be true
			expect( klubs.all? { |g| g.key?('latitude') } ).to be true
			expect( klubs.all? { |g| g.key?('longitude') } ).to be true
			expect( klubs.all? { |g| g.key?('longitude') } ).to be true
		end

		it "should not contain any unwanted keys" do
			allowed_keys = %w[id name slug address town website phone email latitude longitude]

			klubs = JSON.parse(response.body)['klubs']


			klubs.all? do |klub|
				expect(klub.keys).to match_array allowed_keys
			end
		end 
	end
end
