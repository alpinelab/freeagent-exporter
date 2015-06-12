class ArchivesController < ApplicationController
  before_action :find_year, :find_account, only: :index
  before_action :find_archive, only: :update

  def index
    @archives = Array.new(12) do |month|
      Archive.find_or_create_by(bank_account: @account, date: Date.new(@year, month+1, 01))
    end
  end

  def update
    #TODO: check if archive belong to user
    ExpensesImport.perform_async(@archive.id)
    redirect_to archives_path
  end

  private

  def find_archive
    @archive = Archive.find(params[:id])
  end

  def find_year
    @year = (params[:year] || Date.today.year).to_i
  end

  def find_account
    @account = params[:account].present? ? current_user.bank_accounts.find(params[:account]) : current_user.bank_accounts.first
    redirect_to bank_accounts_path if @account.nil?
  end
end
