class Archive < ActiveRecord::Base
  belongs_to :bank_account

  validates :bank_account, presence: true
end
