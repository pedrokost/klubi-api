#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2017-02-06 19:55:12
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-02-06 21:36:39


require 'rails_helper'

describe "Redirect zatresi.si to klubi.si", type: :request do
  context "www.zatresi.si" do
    before(:each) { host! "www.zatresi.si" }
    subject { get "http://www.zatresi.si/karate/banana-split-1?oars=abs" }

    it "should return 301" do
      expect(subject).to eq 301
    end

    it "should redirect to www.klubi.si" do
      expect(subject).to redirect_to("http://www.klubi.si/karate/banana-split-1?oars=abs")
    end
  end

  context "zatresi.si" do
    before(:each) { host! "zatresi.si" }
    subject { get "http://zatresi.si/fitnes" }

    it "should return 301" do
      expect(subject).to eq 301
    end

    it "should redirect to www.klubi.si" do
      expect(subject).to redirect_to("http://www.klubi.si/fitnes")
    end
  end

  context "klubi.si" do
    before(:each) { host! "klubi.si" }
    subject { get "http://klubi.si/oprojektu" }

    it "should return 301" do
      expect(subject).to eq 301
    end

    it "should redirect to www.klubi.si" do
      expect(subject).to redirect_to("http://www.klubi.si/oprojektu")
    end
  end

  context "www.klubi.si" do
    before(:each) { host! "www.klubi.si" }
    subject { get "http://www.klubi.si/karate/" }

    it "should return 200" do
      expect(subject).to eq 200
    end
  end

  context "admin.zatresi.si" do
    before(:each) { host! "admin.zatresi.si" }
    subject { get "http://admin.zatresi.si" }

    it "should return 301" do
      expect(subject).to eq 301
    end

    it "should redirect to admin.klubi.si" do
      expect(subject).to redirect_to("http://admin.klubi.si/")
    end
  end

  context "admin.klubi.si" do
    before(:each) { host! "admin.klubi.si" }

    subject { get "http://admin.klubi.si/klubs" }

    it "should return 401" do
      expect(subject).to eq 401
    end
  end

  context "api.zatresi.si" do
    before(:each) { host! "api.zatresi.si" }
    subject { get "http://api.zatresi.si/klubs?category=fitnes" }

    it "should return 301" do
      expect(subject).to eq 301
    end

    it "should redirect to api.klubi.si" do
      expect(subject).to redirect_to("http://api.klubi.si/klubs?category=fitnes")
    end
  end

  context "api.klubi.si" do
    before(:each) { host! "api.klubi.si" }
    subject { get "http://api.klubi.si/klubs?category=fitnes" }

    it "should return 200" do
      expect(subject).to eq 200
    end
  end

end
