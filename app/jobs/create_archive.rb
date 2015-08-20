class CreateArchive
  include Sidekiq::Worker

  attr_reader :archive

  def perform(archive_id)
    @archive = Archive.find(archive_id)
    archive.update_attributes(transactions_left_to_explain: transactions_left_to_explain)
    if transactions_left_to_explain == 0
      zipfile = ArchiveGenerator.call(archive, bank_transactions, expenses, invoices)
      ArchiveUploader.call(archive, zipfile)
      archive.transition_to :ready
    else
      archive.transition_to :failed
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

  def transactions_left_to_explain
    @transactions_left_to_explain ||= bank_transactions.blank? ? -1 : bank_transactions.select{ |bt| bt.unexplained_amount != 0 }.count
  end
end
