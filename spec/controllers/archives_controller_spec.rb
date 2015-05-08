require 'rails_helper'

describe ArchivesController, "#index", type: :controller do
  context "when user is logged in" do
    before { sign_in User.create! }

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  context "when user is not logged in" do
    it "redirects to sign in page" do
      get :index
      expect(response).to redirect_to new_user_session_path
    end
  end
end
