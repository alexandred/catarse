class Charities::BackersController < ApplicationController
  inherit_resources
  actions :index, :show, :new, :update_info, :review, :create
  skip_before_filter :force_http, only: [:create, :update_info]
  skip_before_filter :verify_authenticity_token, only: [:moip]
  load_and_authorize_resource
  belongs_to :charity

  def update_info
    resource.update_attributes(params[:backer])
    render json: {message: 'updated'}
  end

  def index
    @backers = parent.backers.available_to_count.order("confirmed_at DESC").page(params[:page]).per(10)
    render json: @backers.to_json(can_manage: can?(:update, @project))
  end

  def show
    @title = t('projects.backers.show.title')
    session[:thank_you_backer_id] = nil
  end

  def new
    @create_url = ::Configuration[:secure_review_host] ?
      charity_backers_url(@charity, {host: ::Configuration[:secure_review_host], protocol: 'https'}) :
      charity_backers_path(@charity)

    @title = t('projects.backers.new.title', name: @charity.name)
    @backer = @charity.backers.new(user: current_user)
  end

  def create
    @title = t('projects.backers.create.title')
    @backer.reward_id = nil if params[:backer][:reward_id].to_s == '0'
    @backer.user = current_user
    create! do |success,failure|
      failure.html do
        flash[:failure] = t('projects.backers.review.error')
        return redirect_to new_project_backer_path(@project)
      end
      success.html do
        session[:thank_you_backer_id] = @backer.id
        return render :create
      end
    end
    @thank_you_id = @project.id
  end

  def credits_checkout
    if current_user.credits < @backer.value
      flash[:failure] = t('projects.backers.checkout.no_credits')
      return redirect_to new_project_backer_path(@backer.project)
    end

    unless @backer.confirmed?
      @backer.update_attributes({ payment_method: 'Credits' })
      @backer.confirm!
    end
    flash[:success] = t('projects.backers.checkout.success')
    redirect_to project_backer_path(project_id: parent.id, id: resource.id)
  end
end
