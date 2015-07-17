class ArchiveZipManager
  attr_reader :archive, :bank_transactions, :expenses, :zipname, :tmp_root,:invoices

  def initialize(archive, bank_transactions, expenses, invoices)
    @archive           = archive
    @bank_transactions = bank_transactions
    @expenses          = expenses
    @zipname           = "#{archive.year}-#{format('%02d', archive.month)}-#{SecureRandom.uuid}.zip"
    @tmp_root          = Rails.root.join('tmp', 'archives')
  end

  def generate
    create
    upload
  end

  def self.generate(archive, bank_transactions, expenses, invoices)
    new(archive, bank_transactions, expenses, invoices).generate
  end

private

  def create
    # add_bills
    # add_expenses
    add_invoices
    zipfile.close
  end

  def upload
    s3     = Aws::S3::Resource.new
    bucket = s3.bucket(Rails.application.secrets.aws_s3_bucket_name)
    obj    = bucket.object("#{archive.bank_account.id}/#{zipname}")

    obj.public_url if obj.upload_file("#{tmp_root}/#{zipname}")
  end

  def add_bills
    bank_transactions.each do |bank_transaction|
      bank_transaction.bank_transaction_explanations.each do |explanation|
        ArchiveExplanation.new(explanation).add_to_archive(zipfile) if explanation.attachment.present?
        ArchiveBill.new(explanation.paid_bill, explanation).add_to_archive(zipfile) if explanation.paid_bill.present? && explanation.paid_bill.attachment.present?
      end
    end
  end

  def add_expenses
    expenses.each do |expense|
      ArchiveExpense.new(expense).add_to_archive(zipfile)
    end
  end

  def add_invoices
    bte = bank_transaction_explanations_range
    zipfile.dir.mkdir("invoices")
    invoices.each do |invoice|
      invoice.bank_transaction_explanations = bte[invoice.id]
      ArchiveInvoice.new(invoice).add_to_archive(zipfile)
    end
  end

  def bank_transaction_explanations_range
    btes = FreeAgent::BankTransactionExplanation.find_all_by_bank_account(archive.bank_account.freeagent_id, from_date: archive.start_date, to_date: archive.end_date)

    btes.reduce({}) do |accumulator, explanation|
      if accumulator[explanation.paid_invoice_id].nil?
        accumulator[explanation.paid_invoice_id] = [explanation]
      else
        accumulator[explanation.paid_invoice_id] << explanation
      end
      accumulator
    end
  end

  def zipfile
    @zipfile ||= Zip::File.open("#{tmp_root}/#{zipname}", Zip::File::CREATE)
  end
end
