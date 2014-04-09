class AddDonatorNotificationTypes < ActiveRecord::Migration
  def up
    execute "
    INSERT INTO notification_types (name, created_at, updated_at) VALUES ('confirm_donator', now(), now());
    INSERT INTO notification_types (name, created_at, updated_at) VALUES ('confirm_donation', now(), now())
    "
  end

  def down
    execute "
    DELETE FROM notification_types WHERE name = 'confirm_donator';
    DELETE FROM notification_types WHERE name = 'confirm_donation';
    "
  end
end
