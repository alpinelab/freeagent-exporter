require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_and_belong_to_many :bank_accounts }
  it { should have_many(:archives).through(:bank_accounts) }
end
