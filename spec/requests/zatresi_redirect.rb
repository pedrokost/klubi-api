#!/usr/bin/ruby
# @Author: Pedro Kostelec
# @Date:   2017-02-06 19:55:12
# @Last Modified by:   Pedro Kostelec
# @Last Modified time: 2017-02-06 19:59:01


require 'rails_helper'

describe "Redirect zatresi.si to klubi.si" do
  context "www.zatresi.si" do
    context "new slug format" do
      subject { get "http://www.zatresi.si/karate/banana-split-1?oars=abs" }

      it "should return 301" do
        expect(subject).to eq 301
      end

      it "should redirect to www.klubi.si" do
        expect(subject).to redirect_to("http://www.klubi.si/karate/banana-split-1?oars=abs")
      end
    end
  end

  context "zatresi.si" do
    context "new slug format" do
      subject { get "http://zatresi.si/fitnes" }

      it "should return 301" do
        expect(subject).to eq 301
      end

      it "should redirect to www.klubi.si" do
        expect(subject).to redirect_to("http://www.klubi.si/fitnes")
      end
    end
  end

  context "klubi.si" do
    context "new slug format" do
      subject { get "http://klubi.si/oprojektu" }

      it "should return 301" do
        expect(subject).to eq 301
      end

      it "should redirect to www.klubi.si" do
        expect(subject).to redirect_to("http://www.klubi.si/oprojektu")
      end
    end
  end

  context "www.klubi.si" do
    context "new slug format" do
      subject { get "http://www.klubi.si/karate/" }

      it "should return 200" do
        expect(subject).to eq 200
      end
    end
  end
end
