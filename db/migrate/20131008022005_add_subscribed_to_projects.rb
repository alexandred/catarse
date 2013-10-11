class AddSubscribedToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :subscribed, :boolean
  end
end
