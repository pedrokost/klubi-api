require 'rails_helper'

require 'json'

require 'pry'

RSpec.describe Api::V2::KlubsController, :type => :controller do

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
      klubs = JSON.parse(response.body)['data']
      expect(klubs.length).to eq 2
    end

    it "should return a list of klubs" do
      expect(response.status).to eq 200
      expect(response).to match_response_schema("v2/klubs")
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
        klubs = JSON.parse(response.body)['data']
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
          klubs = json_response[:data]
          expect(response).to match_response_schema("v2/klubs")
          expect(klubs.length).to eq 2
          expect(klubs.map{|h| h[:id]}).to match_array([klub1, klub2].map(&:url_slug))
        end
      end

      context "=gimnastika" do
        before do
          get :index, category: 'gimnastika'
        end

        it "should return only gimnastika klubs" do
          expect(response.status).to eq 200
          klubs = json_response
          expect(response).to match_response_schema("v2/klubs")
          expect(klubs[:data].length).to eq 2
          expect(klubs[:data].map{|h| h[:id]}).to match_array([klub1, klub_branch].map(&:url_slug))
        end
      end

      context "Missing category filter" do
        it "should raise an exception" do
          expect{get :index, category: nil}.to raise_error(ActionController::ParameterMissing)
        end
      end

      context "unsupporte cattegory" do
        before do
          expect(klub2.categories).to include 'fitnes' # expect at least one match
          allow(ENV).to receive(:[]).and_call_original
          expect(ENV).to receive(:[]).with("SUPPORTED_CATEGORIES").and_return('whatever,notit')
          get :index, category: 'fitnes'
        end

        it "should return 200" do
          expect(response).to be_success
        end

        it "should return an empty result set" do
          klubs = json_response
          expect(response).to match_response_schema("v2/klubs")
          expect(klubs[:data].length).to eq 0
        end
      end
    end
  end

  describe 'GET #klubs/:id' do
    let!(:klub1) { FactoryGirl.create(:klub, verified: true, latitude: 20.1, longitude: 10.1, categories: ['fitnes', 'gimnastika']) }
    let!(:klub_branch) { FactoryGirl.create(:klub_branch, verified: true, latitude: 20.1, longitude: 10.1, parent: klub1, categories: ['gimnastika']) }

    before do
      get :show, id: klub1.url_slug
    end

    subject { response }

    it { should be_success }

    it "should return only klub1" do
      expect(json_response[:data].class).to eq Hash
      expect(json_response[:data][:id]).to eq klub1.url_slug
    end

    it "should return the matched klub" do
      expect(response.status).to eq 200
      expect(response).to match_response_schema("v2/klub")
    end

    it "should return the parent's slug" do
      get :show, id: klub_branch.url_slug
      expect(response).to match_response_schema('v2/klub')
      klub = json_response[:data]
      expect(klub[:relationships][:parent][:data][:id]).to eq klub1.url_slug
    end

    context "unsupported cattegory" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("SUPPORTED_CATEGORIES").and_return('whatever,notit')
        get :show, id: klub1.url_slug
      end

      it "should return 200" do
        expect(response).to be_success
      end

      it "should return return the klub" do
        klubs = json_response
        expect(response).to match_response_schema("v2/klub")
        klub = json_response[:data]
        expect(klub[:id]).to eq klub1.url_slug
      end
    end
  end

  describe 'POST #klubs' do

    it "should send an email to admin" do
      expect_any_instance_of(Klub).to receive(:send_review_notification)

      post :create, data: {
        type: 'klubs',
        attributes: {
          name: "Fitnes Maribor",
          categories: ['football']
        }
      }
    end

    it "should send an email to the submitter" do
      expect_any_instance_of(Klub).to receive(:send_thanks_notification)

      post :create, data: {
        type: 'klubs',
        attributes: {
          name: "Qien eres?",
          editor: 'joe@doe.com',
          categories: ['football']
        }
      }
    end

    it "should not send thanks email if no submitter" do
      expect_any_instance_of(Klub).not_to receive(:send_thanks_notification)

      post :create, data: {
        type: 'klubs',
        attributes: {
          name: 'Quien eres?',
          categories: ['football']
        }
      }
    end

    it "should accept categories and other parameters" do

      valid_attrs = {name: "Fitnes Maribor", address: "Mariborska cesta 5", latitude: "46.5534849", longitude: "15.503709399999934", website: "http://www.fitnes-zumba.si",categories: ["fitnes","zumba"], editor: "jaz@ti.com", notes: "Ta klub ne obstaja"}

      expect(Klub).to receive(:new).
        with(valid_attrs.except(:editor))
        .and_return Klub.new(valid_attrs.except(:editor))

      post :create, data: {
        type: 'klubs',
        attributes: valid_attrs
      }
    end

    it "should create a new unverified klub" do
      expect {
        post :create, data: {
          type: 'klubs',
          attributes: {
            name: 'Fitnes Mariborcan 22',
          categories: ['football']
          }
        }
      }.to change(Klub.unscoped, :count).by 1

      klub = Klub.unscoped.last
      expect(klub.verified?).to be_falsy
    end

    it "should return 202 Accepted" do
      post :create, data: {
        type: 'klubs',
        attributes: {
          name: 'Fitnes',
          categories: ['football']
        }
      }

      expect(response.status).to eq 202
    end

    it 'should not create klubs without category' do
      expect {
        post :create, data: {
          type: 'klubs',
          attributes: {
            name: 'Fitnes',
            categories: nil
          }
        }
      }.not_to change(Klub.unscoped, :count)

      expect(response.status).to eq 403
    end

    it "should respond with created klub" do
      post :create, data: {
        type: 'klubs',
        attributes: {
          name: 'Fitnes',
          categories: ['football']
        }
      }

      expect(json_response[:data][:id]).to be_truthy
      expect(json_response[:data][:attributes][:categories]).to match(['football'])
      expect(response).to match_response_schema('v2/klub')
    end
  end

  describe 'PATCH #klub/:id' do

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
        'facebook-url': 'http://facebook.com/newclub'
      }
    end
    let!(:klub) { FactoryGirl.create(:klub, old_attrs.merge(verified: true)) }

    it "should be accepted" do
      patch :update, id: klub.url_slug, data: {
        type: 'klubs',
        attributes: new_attrs
      }
      expect(response.status).to eq 202  # Accepted -- no need to reply with changes
    end

    it "should create Update objects for each changed attributes" do
      expect {
        patch :update, id: klub.url_slug, data: {
          type: 'klubs',
          attributes: new_attrs.merge(editor: 'joe@doe.com')
        }
      }.to change(Update, :count).by(8)

      new_attrs.each do |key, val|
        expect(
          Update.find_by(
            updatable: klub,
            field: key.to_s.underscore,
            oldvalue: old_attrs[key.to_s.underscore.to_sym].to_s,
            newvalue: val.to_s,
            status: :unverified,
            editor_email: 'joe@doe.com'
        )).to be_truthy
      end
    end

    it "should not create Update objects for unchanged attributes" do
      new_attrs = old_attrs.merge(name: 'Some club')

      expect {
        patch :update, id: klub.url_slug, data: {
          type: 'klubs',
          attributes: new_attrs.merge(editor: 'joe@doe.com')
        }
      }.to change(Update, :count).by(1)
    end

    it "should not change the Klub model" do
      patch :update, id: klub.url_slug, data: {
        type: 'klubs',
        attributes: new_attrs.merge(editor: 'joe@doe.com')
      }

      expect(klub.reload).to have_attributes(old_attrs)
    end

    it "should send an email notification to admin" do
      expect_any_instance_of(Klub).to receive(:send_updates_notification)

      patch :update, id: klub.url_slug, data: {
        type: 'klubs',
        attributes: new_attrs.merge(editor: 'joe@doe.com')
      }
    end

    it "should send an email to the editor" do
      expect_any_instance_of(Klub).to receive(:send_confirm_notification)

      patch :update, id: klub.url_slug, data: {
        type: 'klubs',
        attributes: new_attrs.merge(editor: 'joe@doe.com')
      }
    end

    it "should not send confirm email if no editor" do
      expect_any_instance_of(Klub).not_to receive(:send_confirm_notification)

      patch :update, id: klub.url_slug, data: {
        type: 'klubs',
        attributes: new_attrs.merge(editor: nil)
      }
    end
  end
end
