require 'zip/filesystem'
require 'fileutils'
require 'csv'

class ArchiveGenerator
  attr_reader :archive, :bank_transactions, :expenses, :invoices

  def initialize(archive, bank_transactions, expenses, invoices)
    @archive           = archive
    @bank_transactions = bank_transactions
    @expenses          = expenses
    @invoices          = invoices

    add_bills
    add_expenses
    add_invoices
    zipfile
    csv.close
  end

  def csv
    @csv ||= CSV.open(Rails.root.join('tmp', 'csv', csv_filename), "wb")
  end

  def zipfile
    @zipfile ||= Zip::File.open(Rails.root.join('tmp', 'archives', filename), Zip::File::CREATE)
  end
private

  def add_bills
    bank_transactions.each do |bank_transaction|
      bank_transaction.bank_transaction_explanations.each do |explanation|
        ArchiveDocument::Explanation.new(explanation).add_to_archive(zipfile, csv)
        ArchiveDocument::Bill.new(explanation.paid_bill, explanation).add_to_archive(zipfile) if explanation.paid_bill.present?
      end
    end
  end

  def add_expenses
    expenses.each do |expense|
      ArchiveDocument::Expense.new(expense).add_to_archive(zipfile)
    end
  end

  def add_invoices
    invoices.each do |invoice|
      ArchiveDocument::Invoice.new(invoice).add_to_archive(zipfile)
    end
  end

  def filename
    @filename ||= "#{archive.year}-#{format('%02d', archive.month)}-#{SecureRandom.uuid}.zip"
  end

  def csv_filename
    @csv_filename ||= "#{archive.year}-#{format('%02d', archive.month)}-#{SecureRandom.uuid}.csv"
  end

end
