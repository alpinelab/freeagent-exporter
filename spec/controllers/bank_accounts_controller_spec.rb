require 'rails_helper'

describe BankAccountsController, type: :controller do
  let(:user) { User.create! access_token: '12345abc' }

  before do
    stub_request(:get, Regexp.new("https://api.sandbox.freeagent.com/v2/bank_accounts.*")).
      to_return(File.new('spec/api_responses/bank_account_all.json.http'))
    sign_in user
  end

  describe "GET #index" do
    let(:freeagent_bank_accounts) { [FreeAgent::BankAccount.new, FreeAgent::BankAccount.new] }

    it "sets @freeagent_bank_accounts" do
      expect(FreeAgent::BankAccount).to receive(:all).and_return(freeagent_bank_accounts)
      get :index
      expect(assigns(:freeagent_bank_accounts)).to match_array freeagent_bank_accounts
    end

    it "renders index view" do
      expect(get :index).to render_template :index
    end

    it "returns http success" do
      expect(get :index).to have_http_status(:success)
    end

    context "when user is not logged in" do
      before { sign_out user }

      it "redirects to root page" do
        expect(get :index).to redirect_to root_path
      end
    end
  end

  describe "POST #create" do
    it "should be tested"

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

    context "when given bank account belongs to current user" do
      it "destroys the given bank account" do
        expect{ delete :destroy, id: bank_account.id }.to change{BankAccount.count}.by(-1)
      end

      it "sets a success flash message" do
        delete :destroy, id: bank_account.id
        expect(flash[:success]).to_not be_nil
      end
    end

    context "when given bank account is not found in current user bank accounts" do
      let(:user) { User.create! access_token: '12345abc', bank_accounts: [] }

      before { bank_account }

      it "does not destroy given account" do
        expect{ delete :destroy, id: bank_account.id }.to_not change{BankAccount.count}
      end

      it "sets an error flash message" do
        delete :destroy, id: bank_account.id
        expect(flash[:error]).to_not be_nil
      end
    end

    it "redirects to bank accounts index page" do
      delete :destroy, id: bank_account.id
      expect(response).to redirect_to bank_accounts_path
    end

    context "when user is not logged in" do
      before { sign_out user }

      it "redirects to root page" do
        expect(delete :destroy, id: 123).to redirect_to root_path
      end
    end
  end
end
