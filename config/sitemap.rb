# require 'fog/aws'

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://www.klubi.si"
# pick a place safe to write the files
SitemapGenerator::Sitemap.public_path = 'tmp/'
# store on S3 using Fog (pass in configuration values as shown above if needed)
SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new(ENV['AWS_BUCKET'], { path: '' })
# inform the map cross-linking where to find the other maps
SitemapGenerator::Sitemap.sitemaps_host = "http://www.klubi.si/"
# pick a namespace within your bucket to organize your maps
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.verbose = true


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

  supported_categories = ENV['SUPPORTED_CATEGORIES'].split(',')

  # Add all categories
  supported_categories.each do |category|
    add "/#{category}", priority: 0.6, changefreq: 'daily'
    add "/seznam-klubov/#{category}", priority: 0.6, changefreq: 'daily'

    # Add all klubs of supported categories (this may add duplicates - that's
    # fine since the category is different)

    Klub.completed.where('? = ANY (categories)', category).where(closed_at: nil).find_each do |klub|  # does it in batches
      add "/#{category}/#{klub.url_slug}", lastmod: klub.updated_at, changefreq: 'weekly', priority: 0.8
      add "/#{category}/#{klub.url_slug}/uredi", lastmod: klub.updated_at, changefreq: 'weekly', priority: 0.2
      # add "/#{klub.slug}", lastmod: klub.updated_at, changefreq: 'weekly', priority: 0.1
    end
  end

  # See output with:
  # gunzip -c tmp/sitemaps/sitemap.xml.gz | grep -oE "<loc>([^<]+)</loc>"  | cut -c 6- | cut -d'<' -f1



end
