# coding: utf-8
class CharitiesController < ApplicationController
  include ActionView::Helpers::DateHelper
  load_and_authorize_resource only: [:create, :update, :destroy ]

  inherit_resources
  has_scope :pg_search, :by_country
  respond_to :html, except: [:backers]
  respond_to :json, only: [:index, :show, :backers, :update]
  skip_before_filter :detect_locale, only: [:backers]
  
  def new
    return redirect_to plans_path if !current_user
    new! do
      @title = t('charities.new.title')
    end
  end
  
  def search
    @charities = Charity.pg_search(params[:search])
    render :index 
  end
  
  def recommended
    @charities = Charity.recommended
    render :index 
  end
  
  def nearby
    if current_user
      @charities = Charity.by_country(current_user.country)
    else
      redirect_to charities_path and return
    end
    render :index 
  end
  
  def country
    @charities = Charity.by_country(params[:country])
    render :index 
  end
  
  def create
    @charity = current_user.charities.new(params[:charity])

    create!(notice: t('charities.create.success')) do |success, failure|
      success.html{ return redirect_to charity_by_slug_path(@charity.permalink) }
    end
  end
  
  def update
    update! do |success, failure|
      success.html{ return redirect_to charity_by_slug_path(@charity.permalink, anchor: 'edit') }
      failure.html{ return redirect_to charity_by_slug_path(@charity.permalink, anchor: 'edit') }
    end
  end

  def show
    begin
      if params[:id].present?
        @charity = Charity.by_permalink(params[:id]).last
      else
        return redirect_to charity_by_slug_path(resource.permalink)
      end
      if @charity.state != 'online' and (@charity.user != current_user || current_user.admin == false)
        return redirect_to root_path
      end

      show!{
        @title = @charity.name
        fb_admins_add(@charity.user.facebook_id) if @charity.user.facebook_id
        @updates = Array.new
        @charity.updates.order('created_at DESC').each do |update|
          @updates << update if can? :see, update
        end
        @update = @charity.updates.where(id: params[:update_id]).first if params[:update_id].present?
      }
    rescue ActiveRecord::RecordNotFound
      return render_404
    end
  end

  protected

  def resource
    @charity ||= Charity.find params[:id]
  end
end
