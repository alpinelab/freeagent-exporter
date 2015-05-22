class User < ActiveRecord::Base
  devise :omniauthable, :omniauth_providers => [:freeagent]

  has_and_belongs_to_many :bank_accounts
  has_many :archives, through: :bank_accounts

  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid.to_s).first_or_create!(email: auth.info.email)
    user.update_attributes!(access_token: auth.credentials.token)
    user
  end
end
