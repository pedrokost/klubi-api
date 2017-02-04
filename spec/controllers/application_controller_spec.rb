require 'rails_helper'

RSpec.describe ApplicationController, :type => :controller do

  describe "GET #heartbeat" do

    it "returns http success" do
      get :heartbeat
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #index" do
    before do
      returns = [
        '<html>klubi</html>'
      ]
      expect(REDIS).to receive(:get).and_return(*returns)
      get :index
    end

    it "should return some html string" do
      expect(response.body).to match /html/
    end

    it "should return 200" do
      expect(response.status).to eq 200
    end

    context "index_key provided" do
      before do
        returns = [
          '<html>klubi12345</html>',
        ]
        expect(REDIS).to receive(:get).with('klubi:12345').and_return(*returns)
        get :index, index_key: 'klubi:12345'
      end

      it "should return correct index key" do
        expect(response.body).to match /12345/
      end
    end
  end
end
