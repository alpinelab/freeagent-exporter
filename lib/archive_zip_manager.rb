class ArchiveZipManager

  attr_reader :archive, :bank_transactions, :expenses, :filename, :root_path

  def initialize(archive, bank_transactions, expenses)
    @archive           = archive
    @bank_transactions = bank_transactions
    @expenses          = expenses
    @filename          = "#{archive.year}-#{archive.month}-#{SecureRandom.uuid}.zip"
    @root_path         = Rails.root.join('tmp', 'archives')

    FileUtils.mkdir_p(root_path)
    FileUtils.rm_rf(Dir.glob("#{root_path}/*")) #clean the temp folder
  end

  def generate
    create
    upload
  end

  def self.generate(archive, bank_transactions, expenses)
    ArchiveZipManager.new(archive, bank_transactions, expenses).generate
  end

private

  def create
    Zip::File.open("#{root_path}/#{filename}", Zip::File::CREATE) do |zipfile|
      add_bank_transactions(zipfile)
      add_expenses(zipfile)
    end
  end

  def upload
    s3     = Aws::S3::Resource.new
    bucket = s3.bucket(Rails.application.secrets.aws_s3_bucket_name)
    obj    = bucket.object("#{archive.bank_account.id}/#{filename}")

    obj.public_url if obj.upload_file("#{root_path}/#{filename}")
  end

  def add_bank_transactions(zipfile)
    zipfile.dir.mkdir("bank_transactions")
    bank_transactions.each do |bt|
      explanation = FreeAgent::BankTransaction.find(bt.id).bank_transaction_explanations
      add_file_to_archive(zipfile, 'bank_transactions', document_name(explanation, "attachment", explanation.attachment.content_type), explanation.attachment) if explanation.attachment
      add_file_to_archive(zipfile, 'bank_transactions', document_name(explanation, "bill", explanation.paid_bill.attachment.content_type), explanation.paid_bill.attachment) if explanation.paid_bill && explanation.paid_bill.attachment
    end
  end

  def add_expenses(zipfile)
    zipfile.dir.mkdir("expenses")
    expenses.each do |expense|
      add_file_to_archive(zipfile, 'expenses', document_name(expense, "expense", expense.attachment.content_type), expense.attachment) if expense.attachment
    end
  end

  def add_file_to_archive(zipfile, folder, document_name, attachment)
    zipfile.file.open("#{folder}/#{document_name}", "w") do |file|
      file << open(attachment.content_src).read
    end
  end

  def document_name(explanation, type, content_type)
    "#{explanation.id}-#{type}.#{document_extension(content_type)}"
  end

  def document_extension(content_type)
    case content_type
    when "image/jpeg"      then "jpeg"
    when "image/jpg"       then "jpg"
    when "image/png"       then "png"
    when "application/pdf" then "pdf"
    else content_type.split("/").last
    end
  end
end
