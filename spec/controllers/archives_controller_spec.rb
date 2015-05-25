require 'rails_helper'

describe ArchivesController, "#index", type: :controller do
  context "when user is logged in" do
    let(:user)         { User.create! bank_accounts: [bank_account] }
    let(:bank_account) { BankAccount.create! archives: archives }
    let(:archives)     { [Archive.create!, Archive.create!] }

    before { sign_in user }

    it "sets @archives" do
      get :index
      expect(assigns[:archives][bank_account]).to match_array archives
    end

    it "renders index view" do
      expect(get :index).to render_template :index
    end

    it "returns http success" do
      expect(get :index).to have_http_status(:success)
    end
  end

  context "when user is not logged in" do
    it "redirects to root page" do
      get :index
      expect(response).to redirect_to root_path
    end
  end
end
