class AddCharityNotificationTypes < ActiveRecord::Migration
  def up
    execute "
    INSERT INTO notification_types (name, created_at, updated_at) VALUES ('charity_rejected', now(), now());
    INSERT INTO notification_types (name, created_at, updated_at) VALUES ('charity_received', now(), now())
    "
  end

  def down
    execute "
    DELETE FROM notification_types WHERE name = 'charity_rejected';
    DELETE FROM notification_types WHERE name = 'charity_received';
    "
  end
end
