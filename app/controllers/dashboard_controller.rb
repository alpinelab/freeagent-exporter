class DashboardController < ApplicationController

  def index
    @exports = Export.all
  end

end
