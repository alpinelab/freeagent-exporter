require 'rails_helper'

RSpec.describe Archive, type: :model do
  it { should belong_to :bank_account }
end
