#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2017-02-06 19:55:12
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-06-22 21:31:25


require 'rails_helper'

describe "Redirect zatresi.si to klubi.si", type: :request do

  before do
    allow(REDIS).to receive(:get).and_return '<html></html>'
  end

  context "www.zatresi.si" do
    before(:each) { host! "www.zatresi.si" }
    subject { get "http://www.zatresi.si/karate/banana-split-1?oars=abs", {}, { "HTTP_CF_VISITOR" => '{"scheme": "http"}' } }

    it "should return 301" do
      expect(subject).to eq 301
    end

    it "should redirect to www.klubi.si" do
      expect(subject).to redirect_to("https://www.klubi.si/karate/banana-split-1?oars=abs")
    end
  end

  context "zatresi.si" do
    before(:each) { host! "zatresi.si" }
    subject { get "http://zatresi.si/fitnes", {}, { "HTTP_CF_VISITOR" => '{"scheme": "http"}' } }

    it "should return 301" do
      expect(subject).to eq 301
    end

    it "should redirect to www.klubi.si" do
      expect(subject).to redirect_to("https://www.klubi.si/fitnes")
    end
  end

  context "http://klubi.si" do
    before(:each) { host! "klubi.si" }
    subject { get "http://klubi.si/oprojektu", {}, { "HTTP_CF_VISITOR" => '{"scheme": "http"}' } }

    it "should return 301" do
      expect(subject).to eq 301
    end

    it "should redirect to www.klubi.si" do
      # TODO: check protocol
      expect(subject).to redirect_to("https://www.klubi.si/oprojektu")
    end
  end

  context "http://www.klubi.si" do
    before(:each) { host! "www.klubi.si" }
    subject { get "http://www.klubi.si/karate/", {}, { "HTTP_CF_VISITOR" => '{"scheme": "http"}' } }

    it "should 301 to https" do
      expect(subject).to redirect_to("https://www.klubi.si/karate/")
      expect(response.redirect_url).to eq request.url.gsub(/^http:/, 'https:')
    end
  end

  context "as Prerender service" do
    before(:each) do
      host! "www.klubi.si"
    end
    subject { get "http://www.klubi.si/karate/", {}, 'HTTP_USER_AGENT' => "Blah PreRendeR mee" }

    it "should not redirect http -> https" do
      expect(subject).to eq 200
    end
  end

  context "https://www.klubi.si" do
    before(:each) { host! "www.klubi.si" }
    subject { get "https://www.klubi.si/karate/", {}, { "HTTP_CF_VISITOR" => '{"scheme": "https"}' } }

    it "should return 200" do
      expect(subject).to eq 200
    end
  end

  context "admin.zatresi.si" do
    before(:each) { host! "admin.zatresi.si" }
    subject { get "http://admin.zatresi.si", {}, { "HTTP_CF_VISITOR" => '{"scheme": "http"}' } }

    it "should return 301" do
      expect(subject).to eq 301
    end

    it "should redirect to admin.klubi.si" do
      expect(subject).to redirect_to("https://admin.klubi.si/")
    end
  end

  context "admin.klubi.si" do
    before(:each) { host! "admin.klubi.si" }

    subject { get "https://admin.klubi.si/klubs", {}, { "HTTP_CF_VISITOR" => '{"scheme": "https"}' } }

    it "should return 401" do
      expect(subject).to eq 401
    end
  end

  context "api.zatresi.si" do
    before(:each) { host! "api.zatresi.si" }
    subject { get "http://api.zatresi.si/klubs?category=fitnes", {}, { "HTTP_CF_VISITOR" => '{"scheme": "http"}' } }

    it "should return 301" do
      expect(subject).to eq 301
    end

    it "should redirect to api.klubi.si" do
      expect(subject).to redirect_to("https://api.klubi.si/klubs?category=fitnes")
    end
  end

  context "http://api.klubi.si" do
    before(:each) { host! "api.klubi.si" }
    subject { get "http://api.klubi.si/klubs?category=fitnes", {}, { "HTTP_CF_VISITOR" => '{"scheme": "http"}' } }

    it "should return 301" do
      expect(subject).to redirect_to("https://api.klubi.si/klubs?category=fitnes")
    end
  end

  context "https://api.klubi.si" do
    before(:each) { host! "api.klubi.si" }
    subject { get "https://api.klubi.si/klubs?category=fitnes", {}, { "HTTP_CF_VISITOR" => '{"scheme": "https"}' } }

    it "should return 200" do
      expect(subject).to eq 200
    end
  end

end
