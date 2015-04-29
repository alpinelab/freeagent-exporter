class CreateExports < ActiveRecord::Migration
  def change
    create_table :exports do |t|
      t.string :name
      t.string :s3_url
      t.boolean :ticked
      t.timestamps
    end
  end
end
