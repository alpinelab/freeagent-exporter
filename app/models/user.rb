class User < ActiveRecord::Base
  devise :omniauthable, :omniauth_providers => [:freeagent]

  has_and_belongs_to_many :bank_accounts
  has_many :archives, through: :bank_accounts

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid.to_s).first_or_create do |user|
      user.email = auth.info.email
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
