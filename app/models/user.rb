class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, :omniauth_providers => [:freeagent]

  def self.from_omniauth(auth)
    p auth
    where(provider: auth.provider, uid: auth.uid.to_s).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.access_token = auth.credentials.token
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.freeagent_data"] && session["devise.freeagent_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end
end
