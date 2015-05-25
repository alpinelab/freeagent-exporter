class ArchivesController < ApplicationController
  def index
    @year = params[:year] || Date.today.year
    @account = params[:account].present? ? BankAccount.find(params[:account]) : current_user.bank_accounts.first
    @archives = Array.new(12) do |month|
      Archive.find_or_create_by(
        bank_account: @account,
        date: Date.new(@year.to_i, month+1, 01)
      )
    end
  end

  def generate

  end
end
