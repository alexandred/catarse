class CreateCharities < ActiveRecord::Migration
  def change
    create_table :charities do |t|
      t.string :permalink, :name, :charity_url, :registration_number
      t.string :address, :town, :province, :zip, :country
      t.string :email, :phone, :logo, :currency, :video_url
      t.string :state
      t.text :about, :how_know
      t.references :user
      t.timestamps
    end
  end
end
