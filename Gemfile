source 'https://rubygems.org'


gem 'rails', '4.1.8'

gem 'rails-api'

gem 'spring', :group => :development

gem 'unicorn'
gem 'pg'

gem 'rails_12factor', group: :production

gem 'active_model_serializers', '~> 0.9.0'

gem 'redis'

gem 'geocoder'

group :development do
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'pry-byebug'
end

gem 'randexp'

gem 'nokogiri'

gem 'rack-cors', github: 'cyu/rack-cors', require: 'rack/cors'

gem 'rack-rewrite'

gem 'rest_client', require: false

group :development, :test do
	gem 'spring-commands-rspec'
 	gem 'rspec-rails', '~> 3.0'
 	gem 'guard-rspec'
	gem 'factory_girl_rails'
end

gem 'shoulda-matchers', require: false

group :test do
	gem "json-schema"
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano', :group => :development

# To use debugger
# gem 'debugger', :require => 'ruby-debug'

ruby '2.1.5'
