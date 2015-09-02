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
    insert_cancel_order_in_redis(find_jid(archive_id))
  end

private

  def self.find_jid(archive_id)
    workers = Sidekiq::Workers.new
    workers.each do |process_id, thread_id, work|
      return work['payload']['jid'] if work['payload']['class'] == 'CreateArchive' && work['payload']['args'].first == archive_id
    end
    query = Sidekiq::RetrySet.new
    query.select do |job|
      return job.item['jid'] if job.item['class'] == 'CreateArchive' && job.item['args'].first == archive_id
    end
  end

  def self.insert_cancel_order_in_redis(jid)
    Sidekiq.redis {|c| c.setex("cancelled-#{jid}", 86400, 1) }
  end

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
