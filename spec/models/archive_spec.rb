require 'rails_helper'

describe Archive, type: :model do
  it { should belong_to :bank_account }
end
