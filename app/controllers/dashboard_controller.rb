class DashboardController < ApplicationController

  before_action :authenticate_user!, only: :export

  def index
    redirect_to export_path if user_signed_in?
  end

  def export
    @exports = Export.all
  end

end
