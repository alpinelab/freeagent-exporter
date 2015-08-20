class CreateArchive
  include Sidekiq::Worker

  attr_reader :archive

  def perform(archive_id)
    @archive = Archive.find(archive_id)
    archive.update_attributes(transactions_left_to_explain: transactions_left_to_explain)
    if transactions_left_to_explain == 0
      archive_generator = ArchiveGenerator.new(archive, bank_transactions, expenses, invoices)
      zip_url = Uploader.call(archive, archive_generator.zipfile.name)
      csv_url = Uploader.call(archive, archive_generator.csv.path)
      archive.update_attributes(csv_url: csv_url, zip_url: zip_url)
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
