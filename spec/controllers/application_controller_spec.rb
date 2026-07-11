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
      allow_any_instance_of(BootstrapIndexService).to receive(:fetch)
        .and_return('<html>klubi</html>')
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
        allow_any_instance_of(BootstrapIndexService).to receive(:fetch)
          .with('12345').and_return('<html>klubi12345</html>')
        get :index, params: { index_key: '12345' }
      end

      it "should return correct index key" do
        expect(response.body).to match /12345/
      end
    end

    context "invalid index_key" do
      before do
        allow_any_instance_of(BootstrapIndexService).to receive(:fetch)
          .with('klubi:bogus').and_raise(BootstrapIndexService::InvalidRevision)
        get :index, params: { index_key: 'klubi:bogus' }
      end

      it "should return 404" do
        expect(response.status).to eq 404
      end
    end

    context "unknown revision" do
      before do
        allow_any_instance_of(BootstrapIndexService).to receive(:fetch)
          .with('deadbeef').and_raise(Aws::S3::Errors::NoSuchKey.new(nil, 'no such key'))
        get :index, params: { index_key: 'deadbeef' }
      end

      it "should return 404" do
        expect(response.status).to eq 404
      end
    end
  end
end
