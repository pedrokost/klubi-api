require 'rails_helper'

RSpec.describe "application/heartbeat.html.erb", type: :view do
  # pending "add some examples to (or delete) #{__FILE__}"

  it "should contain the keyword `klubi`" do
    render

    expect(rendered).to match /klubi/
  end
end
