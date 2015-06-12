require 'freeagent'
require 'zip/filesystem'
require 'open-uri'
require 'fileutils'

class ExpensesImport
  include Sidekiq::Worker

  def initialize
    @root_path = Rails.root.join('tmp', 'archives')
    @s3 = Aws::S3::Resource.new

    FreeAgent.environment = ENV['FREEAGENT_ENV'].to_sym
    FileUtils.mkdir_p(@root_path)
  end

  def upload_file(filename)
    obj = @s3.bucket(Rails.application.secrets.aws_s3_bucket_name).object("#{@user.id}/#{filename}")
    return obj.presigned_url(:get, expires_in: 604800).to_s if obj.upload_file("#{@root_path}/#{filename}")

    nil
  end

  def attachment_into_zip(zipfile, attachment, folder)
    zipfile.file.open("#{folder}/#{attachment.file_name}", "w") do |file|
      file << open(attachment.content_src).read
    end
  end

  def create_zipfile_from_attachments(filename, bank_transactions, expenses)
    Zip::File.open("#{@root_path}/#{filename}", Zip::File::CREATE) do |zipfile|

      zipfile.dir.mkdir("bank_transactions")
      zipfile.dir.mkdir("expenses")

      bank_transactions.each do |bt|
        explanation = FreeAgent::BankTransaction.find(bt.id).bank_transaction_explanations

        attachment_into_zip zipfile, explanation.attachment, 'bank_transactions' if explanation.attachment
        attachment_into_zip zipfile, explanation.paid_bill.attachment, 'bank_transactions' if explanation.paid_bill
      end

      expenses.each do |expense|
        attachment_into_zip zipfile, expense.attachment, 'expenses' if expense.attachment
      end

    end
  end

  def perform(archive_id)
    archive = Archive.find(archive_id)
    raise "archive not found" if archive.nil?

    unexplained = 0
    date = archive.date.at_beginning_of_month
    @bank_account = archive.bank_account
    @user = @bank_account.users.first

    FreeAgent.access_details(
      Rails.application.secrets.freeagent_id,
      Rails.application.secrets.freeagent_secret,
      access_token: @user.access_token
    )

    FileUtils.rm_rf(Dir.glob("#{@root_path}/*")) #clean the temp folder

    bank_transactions = FreeAgent::BankTransaction.find_all_by_bank_account(
      @bank_account.freeagent_id,
      { from_date: date, to_date: date.at_end_of_month })
    expenses = FreeAgent::Expense.filter(
      { from_date: date, to_date: date.at_end_of_month })

    puts "#{date} got #{bank_transactions.length} bank_transactions and #{expenses.length} expenses"

    bank_transactions.each { |bt| unexplained += 1 if bt.unexplained_amount != 0 }

    archive.update_attributes(n_to_explain: unexplained, name: date.to_s(:month_and_year))

    if unexplained == 0 && bank_transactions.length > 0
      filename = "#{date.to_s(:month_and_year_file)}.zip"
      create_zipfile_from_attachments filename, bank_transactions, expenses
      url = upload_file filename
      archive.update_attributes(s3_url: url) if url
    end
  end
end
