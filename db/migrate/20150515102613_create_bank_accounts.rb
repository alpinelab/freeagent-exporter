class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.string :number
      t.timestamps
    end

    create_table :bank_accounts_users, id: false do |t|
      t.belongs_to :bank_account, index: true
      t.belongs_to :user, index: true
    end

    ActiveRecord::Base.connection.execute 'TRUNCATE TABLE archives'
    rename_column :archives, :user_id, :bank_account_id
  end
end
