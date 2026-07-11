# The GoodJob dashboard engine is mounted on the admin subdomain (routes.rb).
# Administrate's basic auth lives in its controllers, so the engine needs its
# own guard; reuse the same admin credentials.
GoodJob::Engine.middleware.use(Rack::Auth::Basic) do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(username, Rails.application.credentials.ADMIN_NAME.to_s) &
    ActiveSupport::SecurityUtils.secure_compare(password, Rails.application.credentials.ADMIN_PASSWORD.to_s)
end
