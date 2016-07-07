require 'rails_helper'

require 'json'

require 'pry'

RSpec.describe Api::V1::KlubsController, :type => :controller do

  describe 'GET #klubs' do
    let!(:klub1) { FactoryGirl.create(:klub, verified: true, latitude: 20.1, longitude: 10.1, categories: ['fitnes', 'gimnastika']) }
    let!(:klub2) { FactoryGirl.create(:klub, verified: true, latitude: 20.1, longitude: 10.1, categories: ['fitnes']) }
    let!(:klub_branch) { FactoryGirl.create(:klub_branch, verified: true, latitude: 20.1, longitude: 10.1, parent: klub1, categories: ['gimnastika']) }

    before do
      get :index, category: 'fitnes'
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

        get :index, category: 'fitnes'
      end

      it "does not return klubs that are incomplete" do
        # incomplete: no lat, long and name
        klubs = JSON.parse(response.body)['klubs']
        expect(klubs.length).to eq 1
      end
    end

    describe '?category' do

      context "=fitnes" do
        before do
          get :index, category: 'fitnes'
        end
        it "should return only fitnes klubs" do
          expect(response.status).to eq 200
          klubs = json_response[:klubs]
          expect(response).to match_response_schema("klubs")
          expect(klubs.length).to eq 2
          expect(klubs.map{|h| h[:id]}).to match_array([klub1, klub2].map(&:id))
        end
      end

      context "=gimnastika" do
        before do
          get :index, category: 'gimnastika'
        end

        it "should return only gimnastika klubs" do
          expect(response.status).to eq 200
          klubs = json_response[:klubs]
          expect(response).to match_response_schema("klubs")
          expect(klubs.length).to eq 2
          expect(klubs.map{|h| h[:id]}).to match_array([klub1.id, klub_branch.id])
        end
      end

      context "Missing category filter" do
        it "should raise an exception" do
          expect{get :index, category: nil}.to raise_error(ActionController::ParameterMissing)
        end
      end
    end
  end

  describe 'GET #klubs/:id' do
    let!(:klub1) { FactoryGirl.create(:klub, verified: true, latitude: 20.1, longitude: 10.1, categories: ['fitnes', 'gimnastika']) }
    let!(:klub_branch) { FactoryGirl.create(:klub_branch, verified: true, latitude: 20.1, longitude: 10.1, parent: klub1, categories: ['gimnastika']) }

    before do
      get :find_by_slug, slug: klub1.slug
    end

    subject { response }

    it { should be_success }

    it "should return only klub1" do
      klub = JSON.parse(response.body)['klub']
      expect(klub.class).to eq Hash
      expect(klub['slug']).to eq klub1.slug
    end

    it "should return a list of klubs" do
      expect(response.status).to eq 200
      expect(response).to match_response_schema("klub")
    end

    it "should return the parent's slug" do
      get :find_by_slug, slug: klub_branch.slug
      expect(response).to match_response_schema('klub')
      klub = json_response[:klub]
      expect(klub[:parent_id]).to eq klub1.slug
    end
  end

  describe 'POST #klubs' do

    it "should send an email" do
      expect_any_instance_of(Klub).to receive(:send_review_notification)

      post :create, klub: {name: "Fitnes Maribor"}
    end

    it "should accept categories and other parameters" do

      ok_params = {name: "Fitnes Maribor", address: "Mariborska cesta 5", latitude: "46.5534849", longitude: "15.503709399999934", website: "http://www.fitnes-zumba.si",categories: ["fitnes","zumba"], editor: "jaz@ti.com", notes: "Ta klub ne obstaja"}
      expect(Klub).to receive(:new).
        with(ok_params.except(:editor).with_indifferent_access)
        .and_return Klub.new(ok_params.except(:editor))

      post :create, klub: ok_params
    end

    it "should create a new unverified klub" do
      expect {
        post :create, klub: { name: 'Fitnes Mariborcan 22' }
      }.to change(Klub.unscoped, :count).by 1

      klub = Klub.unscoped.last
      expect(klub.verified?).to be_falsy
    end
  end

  describe 'PUT #klub/:id' do

    let(:old_attrs) do
      {
        name: 'Old club',
        address: 'Univerza v Ljubljani, Tržaška cesta 25, 1000 Ljubljana, Slovenija',
        website: 'http://oldclub.com',
        phone: '040 040 040',
        email: 'old@club.com',
        categories: ['fitnes'],
        facebook_url: 'http://facebook.com/oldclub',
        editor_emails: []
      }
    end
    let(:new_attrs) do
      {
        name: 'New club',
        address: 'Trzaska 26, Ljubljana',
        website: 'http://newclub.com',
        phone: '404 404 404',
        email: 'new@club.com',
        categories: ['fitnes', 'rugby'],
        notes: "Kera stvar",
        facebook_url: 'http://facebook.com/newclub'
      }
    end
    let!(:klub) { FactoryGirl.create(:klub, old_attrs.merge(verified: true)) }

    it "should be accepted" do
      patch :update, id: klub.slug, klub: new_attrs
      expect(response.status).to eq 202  # Accepted -- no need to reply with changes
    end

    it "should create Update objects for each changed attributes" do
      expect {
        patch :update, id: klub.slug, klub: new_attrs.merge(editor: 'joe@doe.com')
      }.to change(Update, :count).by(8)

      new_attrs.each do |key, val|
        expect(
          Update.find_by(
            updatable: klub,
            field: key,
            oldvalue: old_attrs[key].to_s,
            newvalue: val.to_s,
            status: :unverified,
            editor_email: 'joe@doe.com'
        )).to be_truthy
      end
    end

    it "should not create Update objects for unchanged attributes" do
      new_attrs = old_attrs.merge(name: 'Some club')

      expect {
        patch :update, id: klub.slug, klub: new_attrs.merge(editor: 'joe@doe.com')
      }.to change(Update, :count).by(1)
    end

    it "should not change the Klub model" do
      patch :update, id: klub.slug, klub: new_attrs.merge(editor: 'joe@doe.com')

      expect(klub.reload).to have_attributes(old_attrs)
    end

    it "should send an email notification" do
      expect_any_instance_of(Klub).to receive(:send_updates_notification)

      patch :update, id: klub.slug, klub: new_attrs.merge(editor: 'joe@doe.com')
    end
  end
end
