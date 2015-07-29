class CreateArchive
  include Sidekiq::Worker

  attr_reader :archive

  def perform(archive_id)
    @archive = Archive.find(archive_id)
    archive.update_attributes(transactions_left_to_explain: transactions_left_to_explain)
    if archive_can_be_generated?
      zipfile = ArchiveGenerator.call(archive, bank_transactions, expenses, invoices)
      ArchiveUploader.call(archive, zipfile)
    end
  end

private

  def data
    @data ||= ArchiveDataFetcher.new(archive)
  end

  def bank_transactions
    @bank_transactions ||= data.bank_transactions
  end

  def expenses
    @expenses ||= data.expenses
  end

  def invoices
    @invoices ||= data.invoices
  end

  def archive_can_be_generated?
    transactions_left_to_explain == 0 && bank_transactions.length > 0 unless bank_transactions.nil?
  end

  def transactions_left_to_explain
    @transactions_left_to_explain ||= bank_transactions.select{ |bt| bt.unexplained_amount != 0 }.count unless bank_transactions.blank?
  end
end
