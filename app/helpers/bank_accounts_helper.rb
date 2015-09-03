module BankAccountsHelper
  def tracked_icon(freeagent_account)
    bank_account = current_user.bank_accounts.find_by(freeagent_id: freeagent_account.id)
    if bank_account
      link_to bank_account_path(id: bank_account.id), method: :delete do
        content_tag :i, '', class: 'icon checkmark', title: 'Click to stop tracking'
      end
    else
      link_to bank_accounts_path(freeagent_id: freeagent_account.id, name: freeagent_account.name, number: freeagent_account.account_number), method: :post do
        content_tag :i, '', class: 'icon remove', title: 'Click to track'
      end
    end
  end
end
