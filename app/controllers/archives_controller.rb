class ArchivesController < ApplicationController
  before_action :find_account, only: :index
  before_action :find_archive, only: [:update, :show]

  def index
    @archives = (1..12).map do |month|
      Archive.find_or_create_by!(bank_account: account, year: year, month: month)
    end
  end

  def show
    respond_to do |format|
      format.html { render partial: 'archives/show', locals: { archive: archive } }
      format.csv { send_data @archive.to_csv, filename: 'test.csv' }
    end
  end

  def show
    redirect_to archives_path if @archive.s3_url.empty?
    respond_to do |format|
      format.html { redirect_to @archive.s3_url }
      format.csv { send_data @archive.to_csv, filename: 'test.csv' }
    end
  end

  def update
    archive.transition_to :generating
    CreateArchive.perform_async(archive.id)
    redirect_to :back
  end

private

  def find_archive
    redirect_to archives_path, notice: t(".no_rights") unless archive.present? && current_user.can_generate?(archive)
  end

  def find_account
    redirect_to bank_accounts_path, notice: t(".no_account") unless account.present?
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
