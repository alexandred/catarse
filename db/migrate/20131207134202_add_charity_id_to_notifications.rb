class AddCharityIdToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :charity_id, :integer
  end
end
