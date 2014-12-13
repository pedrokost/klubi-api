require 'rails_helper'
require 'import/importer'

RSpec.describe Import::Importer do

  let(:datasource) { instance_double(Import::Datasource) }
  let(:transformer) { instance_double(Import::Transformer) }

  subject { Import::Importer.new(datasource, transformer) }

  before do
    data = [
      {
        name: 'Fitnes 1'
      },
      {
        name: 'Fitnes 2'
      }
    ]
    allow(datasource).to receive(:fetch).and_return data
    allow(transformer).to receive(:description).and_return('abracadabra')
    allow(transformer).to receive(:transform).and_return data
  end

  # Pubic methods
  it { is_expected.to respond_to :run }

  # Private methods
  it { is_expected.not_to respond_to :commit }
  it { is_expected.not_to respond_to :commit_one }

  it "should be able to commit an array of klubs data" do
    expect{subject.run}.to change{Klub.unscoped.count}.by 2
  end
end
