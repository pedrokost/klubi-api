source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 7.2.1'

gem 'rack-ssl-enforcer'

gem 'puma', '>= 5.0'
gem 'pg', '~> 1.5.9'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

gem 'activerecord-postgis-adapter', github: "rgeo/activerecord-postgis-adapter"

gem 'rails_12factor', group: :production

# gem 'active_model_serializers', '~> 0.9.0'
gem 'active_model_serializers', '0.10.14'

gem 'active_model_serializers-jsonapi_embedded_records_deserializer', '~> 0.1.1'

gem 'redis', '~> 4.0.2'

gem 'geocoder', '~> 1.2.8'

gem 'skylight', '~> 6.0.4'

gem 'json_spec', '~>1.1.5'

# gem 'newrelic_rpm', '~> 5.3.0.346'

# gem 'google-api-client', '~> 0.53.0'
gem 'googleauth', '~> 1.11.2'
gem 'google-apis-analyticsreporting_v4', '~> 0.17.0'

gem 'koala', '~> 3.6.0'

gem 'validates_email_format_of'

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # gem 'pry-rescue'
  # gem 'pry-stack_explorer'
  # gem 'pry-byebug'
  # gem 'pry-remote'
  gem 'foreman'
  # gem 'spring'
  # gem 'spring-watcher-listen', '~> 2.0.0'
  # gem 'derailed_benchmarks'

  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'
end

gem 'randexp', '~> 0.1.7'

gem 'nokogiri', '~> 1.16.7'

gem 'rack-attack', '~> 4.3.0'

gem 'rack-cors', '~>0.4.1', require: 'rack/cors'

gem 'rack-rewrite', '~> 1.5.1'

gem 'prerender_rails', '~> 1.6.0'

gem 'rest-client', require: false

gem 'tty-prompt', '~> 0.18.1'

gem 'levenshtein-ffi', :require => 'levenshtein'

gem 'aws-sdk-s3' , '~> 1.169.0'  # for uploading the sitemap
gem 'sitemap_generator', '~> 6.3.0'

gem 'administrate', '0.20.1'

# Makes caching into memcacher work
gem "dalli", '~> 2.7.6'
gem "memcachier", '~> 0.0.2'

gem 'raygun4ruby', '~> 4.0.1'

gem "delayed_job_active_record", "~> 4.1.3"

# gem 'pry-rails'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[ mri windows ], require: 'debug/prelude'

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem 'brakeman', require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem 'rubocop-rails-omakase', require: false

  # gem 'spring-commands-rspec'
  gem 'rspec-rails', '~> 6.1.2' 
  # gem 'guard-rspec'
  gem 'factory_bot_rails'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :test do
  gem "json-schema"
  gem 'shoulda-matchers', "~> 6.2.0" #:github => 'thoughtbot/shoulda-matchers'
end

group :assets do
  gem 'uglifier'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano', :group => :development

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# TODO: Rails 5.2.5, 6.0.3.6, and 6.1.3.1 have been released, removing the mimemagic dependency
gem 'mimemagic', github: 'mimemagicrb/mimemagic', ref: '01f92d86d15d85cfd0f20dabd025dcbd36a8a60f'
