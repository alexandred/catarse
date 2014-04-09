class AddDonatorIdToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :donator_id, :integer
    add_column :notifications, :donation_id, :integer
  end
end
