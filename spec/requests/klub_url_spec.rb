#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2017-01-29 16:22:15
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-08-19 22:05:11

require 'rails_helper'

describe "Klub url redirecting" do
  before do
    allow(REDIS).to receive(:get).and_return '<html></html>'
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("SUPPORTED_CATEGORIES").and_return('fitnes,karate')
  end

  context "with existing klub" do
    let!(:klub) { create(:klub, categories: ['karate'], name: 'Banana Split') }

    context "new slug format" do
      subject { get "https://www.klubi.si/karate/banana-split-#{klub.id}" }

      it "should return 200" do
        expect(subject).to eq 200
      end
    end

    context "old slug format" do
      subject { get "https://www.klubi.si/karate/banana-split?aorst=arst" }
      it "should 301 redirect" do
        expect(subject).to eq 301
      end

      it "should redirect to new slug format" do
        expect(subject).to redirect_to("https://www.klubi.si/karate/banana-split-#{klub.id}?aorst=arst")
      end

    end

    context "static urls" do

      subject { get '/oprojektu', headers: { 'HTTPS': 'on' } }

      it "should return 200" do
        expect(subject).to eq 200
      end
    end

    context "/uredi urls" do
      subject { get 'https://www.klubi.si/karate/banana-split/uredi' }

      it "should 301 redirect" do
        expect(subject).to eq 301
      end

      it "should redirect to new slug format" do
        expect(subject).to redirect_to("https://www.klubi.si/karate/banana-split-#{klub.id}/uredi")
      end
    end

    context "unsupported category" do
      # TODO: assert category not uspported

      subject { get 'https://www.klubi.si/lobanja/banana-split' }

      it "should return 200" do
        expect(subject).to eq 200
      end
    end

    context "missing category with only slug" do
      subject { get 'https://www.klubi.si/banana-split' }

      it "should 301 redirect" do
        expect(subject).to eq 301
      end

      it "should redirect to new slug format" do
        expect(subject).to redirect_to("https://www.klubi.si/karate/banana-split-#{klub.id}")
      end
    end

    context "missing category but with uredi" do
      subject { get 'https://www.klubi.si/banana-split/uredi' }

      it "should 301 redirect" do
        expect(subject).to eq 301
      end

      it "should redirect to new slug format" do
        expect(subject).to redirect_to("https://www.klubi.si/karate/banana-split-#{klub.id}/uredi")
      end
    end
  end

  context "with not existing klub" do
    subject { get 'https://www.klubi.si/this-klub-does-not-exist', headers: { 'HTTPS': 'on' } }

    it "should not redirect" do
      expect(subject).to eq 200
    end
  end

  context "root domains" do
    subject { get '/', headers: { 'HTTPS': 'on' } }

    it "should not redirect" do
      expect(subject).to eq 200
    end
  end
end
