class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def home
    redirect_to exports_path if current_user
  end
end
