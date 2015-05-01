require 'freeagent'
require 'zip'
require 'open-uri'
require 'fileutils'

class ExpensesImport
  include Sidekiq::Worker

  def initialize
    @root_path = Rails.root.join('tmp', 'worker')
    @s3 = Aws::S3::Resource.new
    @user = User.first
    raise "User not found" if @user.nil?
    FreeAgent.access_details(
        ENV['FREEAGENT_ID'],
        ENV['FREEAGENT_SECRET'],
        access_token: @user.access_token
      )
    FreeAgent.environment = ENV['FREEAGENT_ENV'].to_sym

    FileUtils.mkdir_p(@root_path)
  end

  def upload_file(filename)
    obj = @s3.bucket(ENV['AWS_BUCKET']).object("#{@user.id}/#{filename}")
    return obj.presigned_url(:get, expires_in: 604800).to_s if obj.upload_file("#{@root_path}/#{filename}")

    nil
  end

  def create_zipfile_from_bank_transactions_attachments(filename, bank_transactions)
    Zip::File.open("#{@root_path}/#{filename}", Zip::File::CREATE) do |zipfile|
      bank_transactions.each do |bt|
        explanation = FreeAgent::BankTransaction.find(bt.id).bank_transaction_explanations.first
        if explanation['attachment']
          filename = explanation['attachment']['file_name']
          full_path = "#{@root_path}/#{filename}"
          open(full_path, 'wb') do |file|
            file << open(explanation['attachment']['content_src']).read
          end
          zipfile.add(filename, full_path)
        end
      end
    end
  end

  def perform(name, count)
    date = (Date.today - 2.years).at_beginning_of_month
    loop do
      FileUtils.rm_rf(Dir.glob("#{@root_path}/*")) #clean the temps folder
      unexplained = 0
      bank_transactions = FreeAgent::BankTransaction.find_all_by_bank_account(ENV['FREEAGENT_BANK_ACCOUNT_ID'], { from_date: date, to_date: date.at_end_of_month })

      puts "#{date} got #{bank_transactions.length} bank_transactions"

      bank_transactions.each { |bt| unexplained += 1 if bt.unexplained_amount != 0 }

      export = Export.find_or_create_by(user: @user, date: date)
      export.update_attributes(n_to_explain: unexplained, name: date.to_s(:month_and_year))

      if unexplained == 0 && bank_transactions.length > 0
        filename = "#{date.to_s(:month_and_year_file)}.zip"
        create_zipfile_from_bank_transactions_attachments filename, bank_transactions
        url = upload_file filename
        export.update_attributes(s3_url: url) if url
      end

      break if date > Date.today.at_end_of_month
      date = date.next_month
    end

  end
end
