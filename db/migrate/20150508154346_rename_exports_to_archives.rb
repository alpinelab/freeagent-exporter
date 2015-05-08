class RenameExportsToArchives < ActiveRecord::Migration
  def change
    rename_table :exports, :archives
  end
end
