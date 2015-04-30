class AddRelationExport < ActiveRecord::Migration
  def change
    add_reference :exports, :user, index: true
    add_column :exports, :date, :datetime
    add_column :exports, :n_to_explain, :integer

    remove_column :exports, :ticked
  end
end
