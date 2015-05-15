class BankAccountsController < ApplicationController
  def index
    @tracked_accounts = current_user.bank_accounts
    @bank_accounts    = FreeAgent::BankAccount.all
  end

  def create
    bank_account = BankAccount.create!(bank_account_params)
    current_user.bank_accounts << bank_account
    flash[:success] = "Bank account successfully tracked"
  rescue StandardError => e
    flash[:error] = "Error: #{e.message}"
  ensure
    redirect_to bank_accounts_path
  end

  def destroy
    current_user.bank_accounts.delete(params[:id])
    flash[:success] = "Bank account successfully untracked"
    redirect_to bank_accounts_path
  end

private

  def bank_account_params
    params.permit(:freeagent_id, :name, :number)
  end
end
