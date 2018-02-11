require 'rails_helper'

require 'json'

require 'pry'

RSpec.describe Admin::KlubsController, :type => :controller do

  # login to http basic auth
  include AuthHelper
  before(:each) do
    http_login
    @request.env["HTTP_REFERER"] = '/'
  end

  describe 'POST #klubs/:id/send_data_verification_email' do
    let!(:klub) { FactoryGirl.create(:complete_klub, email: 'owner@test.com') }

    it "should send an email" do
      expect_any_instance_of(Klub).to receive(:send_request_verify_klub_data_mail).once

      post :send_data_verification_email, params: { id: klub.id }
    end
  end

  describe "POST #klubs/:id/toggleverify" do

    context "setting verification" do
      let!(:klub) { FactoryGirl.create(:complete_klub, verified: false, data_confirmed_at: nil, created_at: 2.days.ago.beginning_of_day) }

      it "set data_confirmed_at if missing" do
        post :toggleverify, params: { id: klub.id }
        klub.reload
        expect(klub.data_confirmed_at).not_to be_nil
        expect(klub.data_confirmed_at).to eq klub.created_at
      end

      it "leave data_confirmed_at if out of date" do
        set_date = DateTime.now.beginning_of_hour
        klub.data_confirmed_at = set_date
        klub.save!

        post :toggleverify, params: { id: klub.id }
        klub.reload
        expect(klub.data_confirmed_at).to eq set_date
      end
    end

    context "un-setting verification" do
      let!(:klub) { FactoryGirl.create(:complete_klub, verified: true, data_confirmed_at: 3.days.ago.beginning_of_hour) }

      it "does not change data_confirmed_at" do
        prev_val = klub.data_confirmed_at
        post :toggleverify, params: { id: klub.id }
        expect( klub.reload.data_confirmed_at ).to eq prev_val
      end
    end
  end
end
