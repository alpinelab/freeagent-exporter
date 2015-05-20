class BankAccountsController < ApplicationController
  def index
    @freeagent_bank_accounts = FreeAgent::BankAccount.all
  end

  def create
    bank_account = BankAccount.find_or_create_by(bank_account_params)
    if bank_account.persisted?
      current_user.bank_accounts << bank_account
      flash[:success] = "Bank account successfully tracked"
    else
      flash[:error] = "Error: #{bank_account.errors.full_messages}"
    end
    redirect_to bank_accounts_path
  end

  def destroy
    bank_account = current_user.bank_accounts.find_by(id: params[:id])
    if bank_account.present?
      bank_account.destroy
      flash[:success] = "Bank account successfully untracked"
    else
      flash[:error] = "Could not find bank account"
    end
    redirect_to bank_accounts_path
  end

private

  def bank_account_params
    params.permit(:freeagent_id, :name, :number)
  end
end
