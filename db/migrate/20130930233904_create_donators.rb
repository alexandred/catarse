class CreateDonators < ActiveRecord::Migration
  def change
    create_table :donators do |t|
      t.text :comment
      t.decimal :amount, precision: 8, scale: 2
      t.boolean :status
      t.boolean :anonymous
      t.references :user
      t.references :project

      t.timestamps
    end
    add_index :donators, :user_id
    add_index :donators, :project_id
  end
end
