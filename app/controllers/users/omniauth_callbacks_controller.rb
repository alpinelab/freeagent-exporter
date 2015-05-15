class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def freeagent
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication
      FreeAgent.access_details(
        Rails.application.secrets.freeagent_id,
        Rails.application.secrets.freeagent_secret,
        access_token: @user.access_token
      )
      set_flash_message(:notice, :success, :kind => "Freeagent") if is_navigational_format?
    else
      session["devise.freeagent_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end
