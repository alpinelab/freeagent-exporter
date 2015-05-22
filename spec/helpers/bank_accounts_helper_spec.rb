require 'rails_helper'

describe BankAccountsHelper, "#tracked_icon(account)", type: :helper do
  let(:account_id)        { 1234 }
  let(:freeagent_account) { FreeAgent::BankAccount.new(name: 'account', account_number: '123abc') }
  let(:user)              { User.create! }

  before do
    allow(helper).to receive(:current_user).and_return(user)
    allow(freeagent_account).to receive(:id).and_return(account_id)
  end

  subject { helper.tracked_icon(freeagent_account) }

  context "when given account exists inn current user bank account" do
    let(:tracked_account)   { BankAccount.create!(freeagent_id: account_id) }

    before { user.bank_accounts << tracked_account }

    it "returns a link to untrack it" do
      expect(subject).to have_selector("a[data-method=delete][href='#{bank_account_path(id: tracked_account.id)}']")
    end
  end

  context "when given account does not exist in current user bank accounts" do
    it "returns a link to track it" do
      expect(subject).to have_selector("a[data-method=post][href='#{bank_accounts_path(freeagent_id: freeagent_account.id, name: freeagent_account.name, number: freeagent_account.account_number)}']")
    end
  end
end
