require 'rails_helper'

describe BankAccountsController, type: :controller do
  let(:user) { User.create! access_token: '12345abc' }

  before do
    stub_request(:get, Regexp.new("https://api.*freeagent.com/v2/bank_accounts.*")).
      to_return(File.new('spec/api_responses/bank_account_all.json.http'))
    sign_in user
  end

  describe "GET #index" do
    let(:freeagent_bank_accounts) { [FreeAgent::BankAccount.new, FreeAgent::BankAccount.new] }

    subject { get :index }

    it "sets @freeagent_bank_accounts" do
      expect(FreeAgent::BankAccount).to receive(:all).and_return(freeagent_bank_accounts)
      subject
      expect(assigns(:freeagent_bank_accounts)).to match_array freeagent_bank_accounts
    end

    it "renders index view" do
      expect(subject).to render_template :index
    end

    it "returns http success" do
      expect(subject).to have_http_status(:success)
    end

    context "when user is not logged in" do
      before { sign_out user }

      it "redirects to root page" do
        expect(subject).to redirect_to root_path
      end
    end
  end

  describe "POST #create" do
    subject { post :create, freeagent_id: 42, name: 'Current account', number: '1234abcdef' }

    context "when the bank account already exists" do
      it "attaches it to the current user" do
        expect{ subject }.to change{user.bank_accounts.count}.by(1)
      end
    end

    context "when the bank account does not exist yet" do
      context "when it can be created" do
        it "creates it" do
          expect{ subject }.to change{BankAccount.count}.by(1)
        end

        it "sets a flash success message" do
          subject
          expect(flash[:success]).to_not be_nil
        end
      end

      context "when it cannot be created" do
        before { allow(BankAccount).to receive(:find_or_create_by).and_return(BankAccount.new) }

        it "sets an error flash message" do
          subject
          expect(flash[:error]).to_not be_nil
        end
      end
    end

    it "redirects to bank accounts index page" do
      expect(post :create).to redirect_to bank_accounts_path
    end

    context "when user is not logged in" do
      before { sign_out user }

      it "redirects to root page" do
        expect(post :create).to redirect_to root_path
      end
    end
  end

  describe "DELETE #destroy" do
    let(:user)         { User.create! access_token: '12345abc', bank_accounts: [bank_account] }
    let(:bank_account) { BankAccount.create! }

    subject { delete :destroy, id: bank_account.id }

    context "when given bank account belongs to current user" do
      it "destroys the given bank account" do
        expect{ subject }.to change{BankAccount.count}.by(-1)
      end

      it "sets a success flash message" do
        subject
        expect(flash[:success]).to_not be_nil
      end
    end

    context "when given bank account is not found in current user bank accounts" do
      let(:user) { User.create! access_token: '12345abc', bank_accounts: [] }

      before { bank_account }

      it "does not destroy given account" do
        expect{ subject }.to_not change{BankAccount.count}
      end

      it "sets an error flash message" do
        subject
        expect(flash[:error]).to_not be_nil
      end
    end

    it "redirects to bank accounts index page" do
      subject
      expect(response).to redirect_to bank_accounts_path
    end

    context "when user is not logged in" do
      before { sign_out user }

      it "redirects to root page" do
        expect(subject).to redirect_to root_path
      end
    end
  end
end
