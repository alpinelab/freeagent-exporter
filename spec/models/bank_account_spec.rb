require 'rails_helper'

RSpec.describe BankAccount, type: :model do
  it { should have_and_belong_to_many :users }
  it { should have_many :archives }
end
