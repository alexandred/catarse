class AddCharityIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :charity_id, :integer
  end
end
