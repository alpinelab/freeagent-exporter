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
  end

  def call
    add_bills
    add_expenses
    add_invoices
    zipfile
  end

  def self.call(archive, bank_transactions, expenses, invoices)
    new(archive, bank_transactions, expenses, invoices).call
  end

private

  def add_bills
    bank_transactions.each do |bank_transaction|
      bank_transaction.bank_transaction_explanations.each do |explanation|
        ArchiveDocument::Explanation.new(explanation).add_to_archive(zipfile, csv_filename)
        ArchiveDocument::Bill.new(explanation.paid_bill, explanation).add_to_archive(zipfile, csv_filename) if explanation.paid_bill.present?
      end
    end
  end

  def add_expenses
    expenses.each do |expense|
      ArchiveDocument::Expense.new(expense).add_to_archive(zipfile, csv_filename)
    end
  end

  def add_invoices
    invoices.each do |invoice|
      ArchiveDocument::Invoice.new(invoice).add_to_archive(zipfile, csv_filename)
    end
  end

  def filename
    @filename ||= "#{archive.year}-#{format('%02d', archive.month)}-#{SecureRandom.uuid}.zip"
  end

  def csv_filename
    @csv_filename ||= "#{Date::MONTHNAMES[archive.month]}.csv"
  end

  def zipfile
    @zipfile ||= Zip::File.open(Rails.root.join('tmp', 'archives', filename), Zip::File::CREATE) do |zipfile|
      zipfile.file.open(csv_filename, "w") do |file|
        file << ["date", "description", "amount", "location"].to_csv
      end
      zipfile.commit
      zipfile
    end
  end
end
