class ArchivesController < ApplicationController
  before_action :find_year, :find_account, only: :index
  before_action :find_archive, only: :update

  def index
    @archives = (1..12).map do |month|
      Archive.find_or_create_by!(bank_account: @account, year: @year, month: month)
    end
  end

  def update
    #TODO: check if archive belong to user
    @archive.transition_to :generating
    CreateArchive.perform_async(@archive.id)
    redirect_to archives_path
  end

  private

  def find_archive
    @archive = Archive.find_by(id: params[:id])
    redirect_to archives_path if @archive.nil?
  end

  def find_year
    @year = (params[:year] || Date.today.year).to_i
  end

  def find_account
    @account = params[:account].present? ? current_user.bank_accounts.find(params[:account]) : current_user.bank_accounts.first
    redirect_to bank_accounts_path, notice: "Please, track at least one bank account" if @account.nil?
  end
end
