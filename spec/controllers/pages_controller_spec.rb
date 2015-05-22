require "rails_helper"

describe PagesController, "#home" do
  context "when user is logged in" do
    before { sign_in User.create! }

    it "redirects to archives page" do
      expect(get :home).to redirect_to archives_path
    end
  end

  context "when user is not signed in" do
    it "renders home view" do
      expect(get :home).to render_template :home
    end
  end
end
