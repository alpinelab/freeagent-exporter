class RemoveNameFromArchives < ActiveRecord::Migration
  def change
    remove_column :archives, :name
    rename_column :archives, :n_to_explain, :transactions_left_to_explain
  end
end
