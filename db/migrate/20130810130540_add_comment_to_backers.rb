class AddCommentToBackers < ActiveRecord::Migration
  def change
    add_column :backers, :comment, :text
  end
end
