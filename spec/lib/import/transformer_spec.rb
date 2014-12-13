require 'rails_helper'
require 'import/transformer'

RSpec.describe Import::Transformer do

  subject { Import::Transformer.new }

  it{ is_expected.to respond_to :description }
  it{ is_expected.to respond_to(:transform).with(1).argument }

end
