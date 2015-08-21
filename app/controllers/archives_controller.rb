class ArchivesController < ApplicationController
  before_action :find_account, only: :index
  before_action :find_archive, only: [:update, :show]
  before_action :find_archives, only: :batch_update

  def index
    @archives = (1..12).map do |month|
      Archive.find_or_create_by!(bank_account: account, year: year, month: month)
    end
  end

  def show
    render partial: 'archives/show', locals: { archive: archive }
  end

  def batch_update
    archives.each do |archive|
      start_generating archive
    end
    redirect_to :back
  end

  def update
    start_generating archive
    redirect_to :back
  end

private

  def start_generating(archive)
    archive.transition_to :generating
    CreateArchive.perform_async(archive.id)
  end

  def find_archives
    redirect_to :back if archives.blank?
  end

  def find_archive
    redirect_to archives_path, notice: t(".no_rights") unless archive.present? && current_user.can_generate?(archive)
  end

  def find_account
    redirect_to bank_accounts_path, notice: t(".no_account") unless account.present?
  end

  def archives
    return nil if params[:archive_ids].nil?
    @archives ||= Archive.where(id: params[:archive_ids].map {|id| id.first})
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
