class AddCharityVisibleToNotificationType < ActiveRecord::Migration
  def up
    execute "
    INSERT INTO notification_types (name, created_at, updated_at) VALUES ('charity_visible', now(), now())
    "
  end

  def down
    execute "
    DELETE FROM notification_types WHERE name = 'charity_visible'
    "
  end
end
