require 'rails_helper'
require 'import/datasource'

RSpec.describe Import::Datasource do

  subject { Import::Datasource.new(:file, 'bla/bla.json') }

  it{ is_expected.to respond_to :fetch }

  context "file source" do
    it "should return file data using fetch" do
      expect(File).to receive(:read).with('bla/bla.json').and_return({
          'carabin' => 'good'
        }.to_json)

      expect(subject.fetch).to eq '{"carabin":"good"}'
    end
  end

  context "url source" do
    subject { Import::Datasource.new(:http, 'www.google.com') }

    it "should return url data using fetch" do
      response = '<html></html>'
      expect(RestClient).to receive(:get).with('www.google.com').and_return(response)

      expect(subject.fetch).to eq response
    end
  end


end
