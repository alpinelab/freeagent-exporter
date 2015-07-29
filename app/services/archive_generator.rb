require 'zip/filesystem'
require 'fileutils'

class ArchiveGenerator
  attr_reader :archive, :bank_transactions, :expenses,:invoices

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
        ArchiveDocument::Explanation.new(explanation).add_to_archive(zipfile) if explanation.attachment.present?
        ArchiveDocument::Bill.new(explanation.paid_bill, explanation).add_to_archive(zipfile) if explanation.paid_bill.present? && explanation.paid_bill.attachment.present?
      end
    end
  end

  def add_expenses
    expenses.each do |expense|
      ArchiveDocument::Expense.new(expense).add_to_archive(zipfile)
    end
  end

  def add_invoices
    bte = bank_transaction_explanations_range
    invoices.each do |invoice|
      invoice.bank_transaction_explanations = bte[invoice.id]
      ArchiveDocument::Invoice.new(invoice).add_to_archive(zipfile)
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

  def filename
    @filename ||= "#{archive.year}-#{format('%02d', archive.month)}-#{SecureRandom.uuid}.zip"
  end

  def zipfile
    @zipfile ||= Zip::File.open(Rails.root.join('tmp', 'archives', filename), Zip::File::CREATE)
  end
end
