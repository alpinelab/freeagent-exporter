class DashboardController < ApplicationController
  def export
    @exports = current_user.exports.order(date: :desc)
  end
end
