class AddFreeagentIdAndNameToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :freeagent_id, :integer
    add_column :bank_accounts, :name, :string
  end
end
