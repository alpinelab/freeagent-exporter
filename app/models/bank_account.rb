class BankAccount < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :archives
end
