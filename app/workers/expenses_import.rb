require 'freeagent'
require 'zip'
require 'open-uri'
require 'fileutils'

class ExpensesImport
  include Sidekiq::Worker

  def perform(name, count)
    root_path = Rails.root.join('tmp', 'worker')
    FileUtils.mkdir_p(root_path)
    s3 = Aws::S3::Resource.new
    user = User.first
    if user
      FreeAgent.access_details(
        ENV['FREEAGENT_ID'],
        ENV['FREEAGENT_SECRET'],
        access_token: user.access_token
      )
      FreeAgent.environment = ENV['FREEAGENT_ENV'].to_sym

      date = (Date.today - 2.years).at_beginning_of_month
      loop do
        FileUtils.rm_rf(Dir.glob("#{root_path}/*"))
        unexplained = 0
        bank_transactions = FreeAgent::BankTransaction.find_all_by_bank_account(ENV['FREEAGENT_BANK_ACCOUNT_ID'], { from_date: date, to_date: date.at_end_of_month })

        puts "#{date} got #{bank_transactions.length} bank_transactions"

        bank_transactions.each do |bt|
          unexplained += 1 if bt.unexplained_amount != 0
        end

        export = Export.find_or_create_by(user: user, date: date)
        export.update_attributes(n_to_explain: unexplained, name: date.to_s(:month_and_year))

        if unexplained == 0 && bank_transactions.length > 0
          zip_file_name = "#{date.to_s(:month_and_year_file)}.zip"
          zip_full_path = "#{root_path}/#{zip_file_name}"
          Zip::File.open(zip_full_path, Zip::File::CREATE) do |zipfile|
            bank_transactions.each do |bt|
              explanation = FreeAgent::BankTransaction.find(bt.id).bank_transaction_explanations.first
              if explanation['attachment']
                filename = explanation['attachment']['file_name']
                full_path = "#{root_path}/#{filename}"
                open(full_path, 'wb') do |file|
                  file << open(explanation['attachment']['content_src']).read
                end
                zipfile.add(filename, full_path)
              end
            end
          end
          obj = s3.bucket(ENV['AWS_BUCKET']).object("#{user.id}/#{zip_file_name}")
          if obj.upload_file(zip_full_path)
            url = obj.presigned_url(:get, expires_in: 604800).to_s
            export.update_attributes(s3_url: url)
          end
        end

        break if date > Date.today.at_end_of_month
        date = date.next_month
      end
    end
  end
end
