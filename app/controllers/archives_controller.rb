class ArchivesController < ApplicationController
  def index
    @archives = current_user.archives.order(date: :desc)
  end
end
