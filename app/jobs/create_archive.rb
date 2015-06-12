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

    puts "#{archive.start_date} got #{bank_transactions.length} bank_transactions and #{expenses.length} expenses"

    archive.update_attributes(transactions_left_to_explain: transactions_left_to_explain)

    if transactions_left_to_explain == 0 && bank_transactions.length > 0
      url = ::ArchiveZipManager.generate(archive, bank_transactions, expenses)
      archive.update_attributes(s3_url: url) if url
    end
  end

private

  def init_freeagent
    FreeAgent.environment = ENV['FREEAGENT_ENV'].to_sym
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
    archive ||= Archive.find(@archive_id)
  end

  def bank_transactions
    @bank_transactions ||= FreeAgent::BankTransaction.find_all_by_bank_account(
      archive.bank_account.freeagent_id,
      { from_date: archive.start_date, to_date: archive.end_date }
    )
  end

  def expenses
    @expenses ||= FreeAgent::Expense.filter(from_date: archive.start_date, to_date: archive.end_date)
  end
end
