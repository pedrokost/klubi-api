# require 'fog/aws'

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://www.zatresi.si"
# pick a place safe to write the files
SitemapGenerator::Sitemap.public_path = 'tmp/'
# store on S3 using Fog (pass in configuration values as shown above if needed)
SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new(ENV['AWS_BUCKET'])
# inform the map cross-linking where to find the other maps
SitemapGenerator::Sitemap.sitemaps_host = "https://s3-#{ENV['AWS_REGION']}.amazonaws.com/#{ENV['AWS_BUCKET']}/"
# pick a namespace within your bucket to organize your maps
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  add '/dodaj-klub'
  add '/seznam-klubov'
  add '/oprojektu'

  MIN_ITEMS_IN_CATEGORY=5
  # Add all categories
  Klub.pluck(:categories).flatten.each_with_object(Hash.new(0)) {
    |o, h| h[o] += 1
  }.select{
    |k, v| v >= MIN_ITEMS_IN_CATEGORY
  }.keys.each do |category|

    add "/#{category}", priority: 0.6, changefreq: 'daily'
    add "/seznam-klubov/#{category}", priority: 0.6, changefreq: 'daily'
  end

  # Add all klubs
  Klub.find_each do |klub|  # does it in batches
    add "/#{klub.categories.first}/#{klub.slug}", lastmod: klub.updated_at, changefreq: 'weekly', priority: 0.8
    add "/#{klub.categories.first}/#{klub.slug}/uredi", lastmod: klub.updated_at, changefreq: 'weekly', priority: 0.2
    add "/#{klub.slug}", lastmod: klub.updated_at, changefreq: 'weekly', priority: 0.1
  end
end
