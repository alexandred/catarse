class AddDefaultMigration < ActiveRecord::Migration
  def self.up
     change_column :users, :locale, :string, :default => "en", :null => false
  end
end