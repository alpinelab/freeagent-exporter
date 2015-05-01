class ChangeTypeForUrl < ActiveRecord::Migration
  def change
      change_column :exports, :s3_url, :text
  end
end
