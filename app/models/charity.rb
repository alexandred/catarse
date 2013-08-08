class Charity < ActiveRecord::Base
  attr_accessor :accepted_terms

  validates_acceptance_of :accepted_terms, on: :create
end
