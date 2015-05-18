class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_user!, :configure_freeagent

private

  def configure_freeagent
    FreeAgent.access_details(
      Rails.application.secrets.freeagent_id,
      Rails.application.secrets.freeagent_secret,
      access_token: current_user.access_token
    ) unless current_user.nil?
  end
end
