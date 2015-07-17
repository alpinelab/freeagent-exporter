require 'freeagent'
require 'zip/filesystem'
require 'open-uri'
require 'fileutils'

class CreateArchive
  include Sidekiq::Worker

  attr_reader :archive_id

  def perform(archive_id)
    @archive_id = archive_id
    init_freeagent

    archive.update_attributes(transactions_left_to_explain: transactions_left_to_explain)
    return unless archive_can_be_generated?

    zipfile = ArchiveGenerator.call(archive, bank_transactions, expenses, invoices)
    ArchiveUploader.call(archive, zipfile)
  end

private

  def archive_can_be_generated?
    transactions_left_to_explain == 0 && bank_transactions.length > 0
  end

  def init_freeagent
    FreeAgent.environment = Rails.application.secrets.freeagent_env.to_sym
    FreeAgent.access_details(
      Rails.application.secrets.freeagent_id,
      Rails.application.secrets.freeagent_secret,
      access_token: archive.bank_account.users.first.access_token
    )
  end

  def transactions_left_to_explain
    @transactions_left_to_explain ||= bank_transactions.select{ |bt| bt.unexplained_amount != 0 }.count
  end

  def archive
    @archive ||= Archive.find(@archive_id)
  end

  def bank_transactions
    @bank_transactions ||= FreeAgent::BankTransaction.find_all_by_bank_account(archive.bank_account.freeagent_id, from_date: archive.start_date, to_date: archive.end_date)
  end

  def expenses
    @expenses ||= FreeAgent::Expense.filter(from_date: archive.start_date, to_date: archive.end_date)
  end

  def invoices
    @invoices ||= FreeAgent::Invoice.filter(from_date: archive.start_date, to_date: archive.end_date, nested_invoice_items: 'true')
  end
end
