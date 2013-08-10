class AddCharityIdToBackers < ActiveRecord::Migration
  def change
    add_column :backers, :charity_id, :integer
  end
end
