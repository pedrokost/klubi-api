module AuthHelper
  def http_login
    username = ENV['ADMIN_NAME']
    password = ENV['ADMIN_PASSWORD']
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end
end
