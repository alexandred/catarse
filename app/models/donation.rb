class Donation < ActiveRecord::Base
  belongs_to :users
  belongs_to :charities
  attr_accessible :amount, :comment, :status, :anonymous
end
