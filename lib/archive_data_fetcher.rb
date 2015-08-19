require 'freeagent'

class ArchiveDataFetcher
  attr_reader :archive

  def initialize(archive)
    @archive = archive
    init_freeagent
  end

  def bank_transactions
    FreeAgent::BankTransaction.find_all_by_bank_account(archive.bank_account.freeagent_id, from_date: archive.start_date, to_date: archive.end_date)
  end

  def expenses
    FreeAgent::Expense.filter(from_date: archive.start_date, to_date: archive.end_date)
  end

  def invoices
    FreeAgent::Invoice.filter_by_date(archive.start_date, archive.end_date)
  end

private

  def init_freeagent
    FreeAgent.environment = Rails.application.secrets.freeagent_env.to_sym
    FreeAgent.access_details(
      Rails.application.secrets.freeagent_id,
      Rails.application.secrets.freeagent_secret,
      access_token: archive.bank_account.users.first.access_token
    )
  end
end
