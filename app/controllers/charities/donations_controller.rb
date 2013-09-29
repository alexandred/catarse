class Charities::DonationsController < ApplicationController
  inherit_resources
  actions :index, :new, :create
	skip_before_filter :force_http, only: [:create]
  load_and_authorize_resource
	belongs_to :charity
  def new
    @create_url = ::Configuration[:secure_review_host] ?
      charity_donations_url(@charity, {host: ::Configuration[:secure_review_host], protocol: 'https'}) :
      charity_donations_path(@charity)

    @title = t('projects.backers.new.title', name: @charity.name)
    @donation = @charity.donations.new(user: current_user)
  end

  def index
  end

  def create
    response = @donation.payment(@charity, @donation.amount)
      if response.success?
        return redirect_to response.approve_paypal_payment_url
      else
        flash[:failure] = response.errors.first['message']
        return redirect_to new_charity_donation_path(@charity)
      end
  end

  def return
    create! do |success,failure|
      failure.html do
        flash[:failure] = t('projects.backers.review.error')
        return redirect_to new_charity_donation_path(@charity)
      end
      success.html do
        return redirect_to charity_path(@charity)
      end
    end
  end
end
