require 'rails_helper'

require 'json'

require 'pry'

RSpec.describe Admin::UpdatesController, :type => :controller do

  # login to http basic auth
  include AuthHelper
  before(:each) do
    http_login
  end


  describe 'PUT #updates/:id' do

    let!(:klub) { FactoryGirl.create(:complete_klub) }
    let!(:update) { FactoryGirl.create(:update, updatable: klub, field: 'name', oldvalue: klub.name, newvalue: 'Scented') }

    it "should be accepted" do
      # binding.pry
      put :update, id: update.id, update: { status: :rejected }
      expect(response.status).to eq 302
    end

    it "should call the resolve! function" do
      expect{
        put :update, id: update.id, update: { status: :accepted }
        klub.reload
      }.to change(klub, :name)
    end
  end
end
