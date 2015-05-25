class ArchivesController < ApplicationController
  def index
    @year = params[:year].to_i == 0 ? Date.today.year : params[:year].to_i
    @account = params[:account].present? ? current_user.bank_accounts.find(params[:account]) : current_user.bank_accounts.first
    @archives = Array.new(12) do |month|
      Archive.find_or_create_by(bank_account: @account, date: Date.new(@year, month+1, 01))
    end
  end

  def update
    #TODO: check if archive belong to user
    archive = Archive.find(params[:id])
    ExpensesImport.perform_async(archive.id)
    redirect_to archives_path
  end
end
