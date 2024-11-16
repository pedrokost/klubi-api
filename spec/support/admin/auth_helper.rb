module AuthHelper
  def http_login
    username = Rails.application.credentials.ADMIN_NAME
    password = Rails.application.credentials.ADMIN_PASSWORD
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end
end
