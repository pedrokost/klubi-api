require 'rails_helper'

RSpec.describe "routing to klub", :type => :routing do

  let(:url)         { "http://www.domain.si"     }
  let(:api_url)     { "http://api.domain.si"     }

  it "routes / to application#index" do
    expect(get: '/').to route_to(
      controller: 'application',
      action: 'index'
    )
  end

  it "routes /:klub to application#index" do
    expect(get: '/karate-klub-7').to route_to(
      controller: 'application',
      action: 'index',
      path: 'karate-klub-7'
    )
  end

  it "does not route api.* to application#index" do
    expect(get: "#{api_url}").not_to be_routable
  end
end
