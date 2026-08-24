require 'rails_helper'

describe "Sitemap redirect", type: :request do
  before(:each) { host! "www.klubi.si" }

  subject { get "https://www.klubi.si/sitemaps/sitemap.xml.gz", headers: { "HTTP_CF_VISITOR" => '{"scheme": "https"}' } }

  it "redirects to the sitemap on S3" do
    expect(subject).to redirect_to("https://s3.eu-central-1.amazonaws.com/www.klubi.si/sitemaps/sitemap.xml.gz")
  end
end
