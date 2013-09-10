class AddCharityIdToAssociations < ActiveRecord::Migration
  def change
    add_column :updates, :charity_id, :integer
  end
end
