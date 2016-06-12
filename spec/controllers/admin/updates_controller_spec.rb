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

    let!(:klub) { FactoryGirl.create(:complete_klub, editor_emails: ['owner@email.com']) }
    let!(:update) { FactoryGirl.create(:update, updatable: klub, field: 'name', oldvalue: klub.name, newvalue: 'Scented', editor_email: 'editor@email.com') }

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

    it "should add the editor to the list" do
      put :update, id: update.id, update: { status: :accepted }
      klub.reload

      expect(klub.editor_emails).to include 'editor@email.com'
    end

    it "should not add duplicate editors to the list" do
      update.editor_email = 'owner@email.com'
      update.save

      put :update, id: update.id, update: { status: :accepted }
      klub.reload

      expect(klub.editor_emails.length).to eq 1
    end
  end
end
