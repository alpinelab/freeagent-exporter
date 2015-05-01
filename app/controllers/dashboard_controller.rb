class DashboardController < ApplicationController

  before_action :authenticate_user!, only: :export

  def index
    redirect_to export_path if user_signed_in?
  end

  def export
    @exports = current_user.exports.order(date: :desc)
  end

end
