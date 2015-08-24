class CreateArchive
  include Sidekiq::Worker

  attr_reader :archive

  def perform(archive_id)
    return if cancelled?
    @archive = Archive.find(archive_id)
    archive.update_attributes(transactions_left_to_explain: transactions_left_to_explain)
    if transactions_left_to_explain == 0
      zipfile = ArchiveGenerator.call(archive, bank_transactions, expenses, invoices)
      RemoteArchive::Uploader.call(archive, zipfile)
      archive.transition_to :ready
    else
      archive.transition_to :failed
    end
  end

  def self.cancel!(archive_id)
    workers = Sidekiq::Workers.new
    workers.each do |process_id, thread_id, work|
      if work['payload']['class'] == 'CreateArchive' && work['payload']['args'].first == archive_id
        Sidekiq.redis {|c| c.setex("cancelled-#{work['payload']['jid']}", 86400, 1) }
      end
    end
  end

private

  def cancelled?
    Sidekiq.redis {|c| c.exists("cancelled-#{jid}") }
  end

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
