class ArchivesController < ApplicationController
  def index
    @archives = {}
    current_user.bank_accounts.each do |account|
      @archives[account] = account.archives.order(date: :desc)
    end
  end
end
