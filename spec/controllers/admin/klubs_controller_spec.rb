require 'rails_helper'

require 'json'

require 'pry'

RSpec.describe Admin::KlubsController, :type => :controller do

  # login to http basic auth
  include AuthHelper
  before(:each) do
    http_login
  end

  describe 'POST #klubs/:id/send_data_verification_email' do
    let!(:klub) { FactoryGirl.create(:complete_klub, email: 'owner@test.com') }

    it "should send an email" do

      expect_any_instance_of(Klub).to receive(:send_request_verify_klub_data_mail).once

      @request.env["HTTP_REFERER"] = '/'
      post :send_data_verification_email, id: klub.id
    end
  end
end
