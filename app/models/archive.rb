require 'csv'

class Archive < ActiveRecord::Base
  belongs_to :bank_account

  validates_presence_of :bank_account, :year
  validates_uniqueness_of :month, scope: :year

  def start_date
    Date.new(year, month, 01)
  end

  def end_date
    start_date.at_end_of_month
  end

  def to_csv
    CSV.generate do |csv|
      FreeAgent::BankTransaction.find_all_by_bank_account(bank_account.freeagent_id, {from_date: start_date, to_date: end_date}).each do |bt|
        FreeAgent::BankTransaction.find(bt.id).bank_transaction_explanations.each do |explanation|
          csv << [bt.id, "#{explanation.id}-attachment.png"] if explanation.attachment
          csv << [bt.id, "#{explanation.id}-bill.png"] if explanation.paid_bill && explanation.paid_bill.attachment
        end
      end
    end
  end

end
