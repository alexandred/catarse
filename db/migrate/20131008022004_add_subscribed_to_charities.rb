class AddSubscribedToCharities < ActiveRecord::Migration
  def change
    add_column :charities, :subscribed, :boolean
  end
end
