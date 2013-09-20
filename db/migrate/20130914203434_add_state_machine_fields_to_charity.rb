class AddStateMachineFieldsToCharity < ActiveRecord::Migration
  def change
    add_column :charities, :online_date, :date 
  end
end
