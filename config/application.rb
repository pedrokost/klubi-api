require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module KlubiApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")


    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    # Administrate require api_only to be set to false!
    config.api_only = false

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.i18n.default_locale = :sl

    config.i18n.fallbacks =[:en]


    config.middleware.insert_before ActionDispatch::Static, Rack::Cors, logger: Rails.logger do
      allow do
        origins 'app.local:4200', 'localhost:8000', 'klubi.si', 'dev.klubi.si', 'www.klubi.si', 'd2ne2albfoowfo.cloudfront.net', '*'

        resource '*',
          :headers => :any,
          :methods => [:get, :post, :delete, :put, :patch, :options, :head],
          :max_age => 1728000
      end
    end

    # Clouldflare with Flexible SSL causes that the server does not directly
    # know if the request comes form HTTP or HTTPS. Looking at the header
    # HTTP_CF_VISITOR I can learn what protocol was used and act accordingly.
    # I do not redirect any of the request which don't have the header (meaning
    # I left clouldflare). I also do not do the 301 if the request comes from
    # Prerender.
    config.middleware.insert_before ActionDispatch::Static, Rack::SslEnforcer, except_agents: /prerender/i, ignore: lambda { |request|

      clould_flare_visitor = JSON.parse(request.env["HTTP_CF_VISITOR"])['scheme'] if request.env["HTTP_CF_VISITOR"]
      clould_flare_https = clould_flare_visitor.match(/https/i) if clould_flare_visitor
      request.env["HTTPS"] == 'on' || clould_flare_https || Rails.env.development?
    }

    config.middleware.insert_before(Rack::Cors, Rack::Rewrite) do

      # Redirect to the www version of the domain
      r301 %r{.*}, "https://www.klubi.si$&", :if => Proc.new {|rack_env|
        ["klubi.si", "www.zatresi.si", "zatresi.si"].include? rack_env['SERVER_NAME']
      }

      # Redirect the admin from old domain to the new domain
      r301 %r{.*}, "https://admin.klubi.si$&", :if => Proc.new {|rack_env|
        ["admin.zatresi.si"].include? rack_env['SERVER_NAME']
      }

      r301 %r{.*}, "https://api.klubi.si$&", :if => Proc.new {|rack_env|
        ["api.zatresi.si"].include? rack_env['SERVER_NAME']
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
    config.skylight.probes += %w(redis active_model_serializers active_job)

    config.active_job.queue_adapter = :delayed_job
  end
end
