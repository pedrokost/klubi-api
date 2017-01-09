Raygun.setup do |config|
  config.api_key = "8yPNkPm1E+RoUZ8jSdhwkA=="
  config.filter_parameters = Rails.application.config.filter_parameters

  # The default is Rails.env.production?
  # config.enable_reporting = !Rails.env.development? && !Rails.env.test?

  config.ignore.delete('ActiveRecord::RecordNotFound')
end
