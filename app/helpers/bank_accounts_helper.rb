module BankAccountsHelper
  def tracked_icon(account)
    bank_account = current_user.bank_accounts.find_by(freeagent_id: account.id)
    if bank_account
      link_to bank_account_path(id: bank_account.id), method: :delete do
        content_tag :span, '', class: 'glyphicon glyphicon-ok'
      end
    else
      link_to bank_accounts_path(freeagent_id: account.id, name: account.name, number: account.account_number), method: :post do
        content_tag :span, '', class: 'glyphicon glyphicon-remove'
      end
    end
  end
end
