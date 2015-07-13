class ArchiveZipManager
  attr_reader :archive, :bank_transactions, :expenses, :zipname, :tmp_root

  def initialize(archive, bank_transactions, expenses)
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

  def self.generate(archive, bank_transactions, expenses)
    new(archive, bank_transactions, expenses).generate
  end

private

  def create
    add_bills
    add_expenses
    zipfile.close
  end

  def upload
    s3     = Aws::S3::Resource.new
    bucket = s3.bucket(Rails.application.secrets.aws_s3_bucket_name)
    obj    = bucket.object("#{archive.bank_account.id}/#{zipname}")

    obj.public_url if obj.upload_file("#{tmp_root}/#{zipname}")
  end

  def add_bills
    zipfile.dir.mkdir("bills")
    bank_transactions.each do |bank_transaction|
      bank_transaction.bank_transaction_explanations.each do |explanation|
        ArchiveDocument.new(explanation).add_to_archive(zipfile) if explanation.attachment.present?
        ArchiveDocument.new(explanation.paid_bill, explanation).add_to_archive(zipfile) if explanation.paid_bill.present? && explanation.paid_bill.attachment.present?
      end
    end
  end

  def add_expenses
    zipfile.dir.mkdir("expenses")
    expenses.each do |expense|
      ArchiveDocument.new(expense).add_to_archive(zipfile)
    end
  end

  def zipfile
    @zipfile ||= Zip::File.open("#{tmp_root}/#{zipname}", Zip::File::CREATE)
  end
end
