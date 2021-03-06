class Projects::DonatorsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  inherit_resources
  actions :index, :new, :create, :return
  skip_before_filter :force_http, only: [:create]
  load_and_authorize_resource
  belongs_to :project
  def new
    if params[:redirect] == "true"
      session[:return_to] = new_project_donator_path(@project)
     return redirect_to new_user_session_path
    end
    @create_url = ::Configuration[:secure_review_host] ?
      project_donators_url(@project, {host: ::Configuration[:secure_review_host], protocol: 'https'}) :
      project_donators_path(@project)

    @title = t('projects.backers.new.title', name: @project.name)
    @donator = @project.donators.new(user: current_user)
  end

  def index
    @donators = @project.donators
  end

  def create
    if params[:donator][:amount] == "" || params[:donator][:amount] == "0"
      flash[:error] = "You must enter a donation"
      return redirect_to new_project_donator_path(@project)
    end
    user_id = current_user ? current_user.id : nil
    response = @donator.payment(@project, @donator,user_id)
      if response.success?
        return redirect_to response.approve_paypal_payment_url
      else
        flash[:failure] = response.errors.first['message']
        return redirect_to new_project_donator_path(@project)
      end
  end

  def return
    if params.has_key?(:project_id) and params.has_key?(:amt)
      project = Project.find(params[:project_id])
      flash[:success] = "Thank you for your donation of #{number_to_currency(params[:amt], unit: project.currency_symbol)} to #{project.name}."
      redirect_to project_by_slug_path(permalink: project.permalink)
    else
      redirect_to root_path
    end
  end
end
