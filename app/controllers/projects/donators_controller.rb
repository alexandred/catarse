class Projects::DonatorsController < ApplicationController
  inherit_resources
  actions :index, :new, :create, :return
  skip_before_filter :force_http, only: [:create]
  load_and_authorize_resource
  belongs_to :project
  def new
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
    response = @donator.payment(@project, @donator,current_user.id)
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
      flash[:success] = "Thank you for your donation of #{params[:amt]} #{project.currency} to #{project.name}."
      redirect_to project_path(project)
    else
      redirect_to root_path
    end
  end
end
