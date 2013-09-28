class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.text :comment
      t.decimal :amount, precision: 8, scale: 2
      t.boolean :status
      t.boolean :anonymous
      t.references :user
      t.references :charity

      t.timestamps
    end
    add_index :donations, :user_id
    add_index :donations, :charity_id
  end
end
