class DashboardController < ApplicationController

  def index
    client = oauth2_freeagent_client
    setting = Setting.first
    @authorize_url = client.auth_code.authorize_url(:redirect_uri => ENV['FREEAGENT_CALLBACK']) if setting.nil?

    if setting
      token = OAuth2::AccessToken.new(client, setting.token)
      @company = token.get('/v2/company')
      resp = JSON.parse @company.body
      @company_name = resp["company"]["name"]
    end
    @exports = Export.all
  end


  def callback
    setting = Setting.first
    token = oauth2_freeagent_client.auth_code.get_token(params['code'], :redirect_uri => ENV['FREEAGENT_CALLBACK'])
    setting.nil? ? Setting.create(token: token.token) : setting.update_attributes(token: token.to_hash)
    redirect_to root_path
  end

end
