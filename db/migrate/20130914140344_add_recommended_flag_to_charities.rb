class AddRecommendedFlagToCharities < ActiveRecord::Migration
  def change
    add_column :charities, :recommended, :boolean, :default => false
  end
end
