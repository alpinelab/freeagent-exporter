module HeaderHelper
  def link_to_bank_accounts
    link_to bank_accounts_path do
      content_tag(:div,
        content_tag(:i, "", class: %w{money icon}) + "  Bank Accounts",
        class: "item"
      )
    end
  end

  def link_to_sign_out
    link_to destroy_session_path, method: :delete do
      content_tag(:div,
        content_tag(:i, "", class: %w{sign out icon}) + " Sign Out",
        class: "item"
      )
    end
  end
end
