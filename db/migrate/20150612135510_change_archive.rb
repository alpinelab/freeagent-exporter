class ChangeArchive < ActiveRecord::Migration
  def change
    add_column :archives, :month, :integer
    add_column :archives, :year, :integer
    remove_column :archives, :date
  end
end
