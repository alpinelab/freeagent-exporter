class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def oauth2_freeagent_client
    OAuth2::Client.new(
      ENV['FREEAGENT_ID'],
      ENV['FREEAGENT_SECRET'],
      site: ENV['FREEAGENT_URL'],
      authorize_url: '/v2/approve_app',
      token_url: '/v2/token_endpoint')
  end
end
