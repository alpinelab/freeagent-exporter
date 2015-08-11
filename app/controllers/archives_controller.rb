class ArchivesController < ApplicationController
  before_action :find_account, only: :index
  before_action :find_archive, only: :update

  def index
    @archives = (1..12).map do |month|
      Archive.find_or_create_by!(bank_account: account, year: year, month: month)
    end
  end

  def update
    #TODO: check if archive belong to user
    archive.transition_to :generating
    CreateArchive.perform_async(archive.id)
    redirect_to :back
  end

private

  def find_archive
    redirect_to archives_path unless archive.present?
  end

  def find_account
    redirect_to bank_accounts_path, notice: "Please, track at least one bank account" unless account.present?
  end

  def account
    @account ||= params[:account].present? ? current_user.bank_accounts.find(params[:account]) : current_user.bank_accounts.first
  end

  def archive
    @archive ||= Archive.find_by(id: params[:id])
  end

  def year
    @year ||= (params[:year] || Date.today.year).to_i
  end
end
