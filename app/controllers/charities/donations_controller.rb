class Charities::DonationsController < ApplicationController
  inherit_resources
  actions :index, :new, :create, :return
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
    @donations = @charity.donations
  end

  def create
    response = @donation.payment(@charity, @donation,current_user.id)
      if response.success?
        return redirect_to response.approve_paypal_payment_url
      else
        flash[:failure] = response.errors.first['message']
        return redirect_to new_charity_donation_path(@charity)
      end
  end

  def return
    if params.has_key?(:charity_id) and params.has_key?(:amt)
      charity = Charity.find(params[:charity_id])
      flash[:success] = "Thank you for your donation of #{params[:amt]} #{charity.currency} to #{charity.name}."
      redirect_to charity_path(charity)
    else
      redirect_to root_path
    end
  end
end
