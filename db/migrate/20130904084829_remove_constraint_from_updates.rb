class RemoveConstraintFromUpdates < ActiveRecord::Migration
  def up
    change_column :updates, :project_id, :integer, :null => true, :foreign_key => false
    change_column :updates, :charity_id, :integer, :null => true, :foreign_key => false
  end

  def down
  end
end
