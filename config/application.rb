require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module KlubiApi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.i18n.default_locale = :si

    config.i18n.fallbacks =[:en]

    config.middleware.insert_before ActionDispatch::Static, Rack::Cors, logger: Rails.logger do
      allow do
        origins 'app.local:4200' , 'klubi.si', 'dev.klubi.si', 'www.klubi.si', 'd2ne2albfoowfo.cloudfront.net', '*'

        resource '*',
          :headers => :any,
          :methods => [:get, :post, :delete, :put, :patch, :options, :head],
          :max_age => 1728000
      end
    end

    config.middleware.insert_before(Rack::Cors, Rack::Rewrite) do

      # Redirect to the www version of the domain
      r301 %r{.*}, "http://www.klubi.si$&", :if => Proc.new {|rack_env|
        ["klubi.si", "www.zatresi.si", "zatresi.si"].include? rack_env['SERVER_NAME']
      }

    end

    config.action_dispatch.default_headers = {
        'X-Frame-Options' => 'ALLOWALL'
    }

    config.middleware.use Rack::Attack
    config.middleware.use ActionDispatch::Flash
    config.middleware.use Rack::MethodOverride

    config.active_record.schema_format = :sql


    # Skylight config
    config.skylight.probes += %w(redis active_model_serializers)
  end
end
