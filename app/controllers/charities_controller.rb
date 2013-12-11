# coding: utf-8
class CharitiesController < ApplicationController
  include ActionView::Helpers::DateHelper
  load_and_authorize_resource only: [:new, :create, :update, :destroy ]

  inherit_resources
  has_scope :pg_search, :by_country
  respond_to :html, except: [:backers]
  respond_to :json, only: [:index, :show, :backers, :update]
  skip_before_filter :detect_locale, only: [:backers]
  
  def new
    new! do
      @title = t('charities.new.title')
    end
  end
  
  def search
    @charities = Kaminari.paginate_array(Charity.where(state: 'online').pg_search(params[:search]).sort_by{|e| e[:name]}).page(params[:page]).per(10)
    render :index 
  end
  
  def recommended
    @charities = Kaminari.paginate_array(Charity.where(state: 'online').recommended.sort_by{|e| e[:name]}).page(params[:page]).per(10)
    render :index
  end
  
  def nearby
    if current_user
      @charities = Kaminari.paginate_array(Charity.where(state: 'online').by_country(current_user.country).sort_by{|e| e[:name]}).page(params[:page]).per(10)
    else
      redirect_to charities_path and return
    end
    render :index 
  end
  
  def country
    @charities = Kaminari.paginate_array(Charity.where(state: 'online').by_country(params[:country]).sort_by{|e| e[:name]}).page(params[:page]).per(10)
    render :index 
  end

  def recent
    @charities = Kaminari.paginate_array(Charity.where("current_timestamp - charities.online_date <= '5 days'::interval").sort_by{|e| e[:name]}).page(params[:page]).per(10)
    render :index
  end

  def index
    index! do
      @title = "Charities"
      @charities = Kaminari.paginate_array(Charity.where(state: 'online').all.sort_by{|e| e[:name]}).page(params[:page]).per(10)
    end
  end
  
  def create
    @charity = current_user.charities.new(params[:charity])

    create!(notice: t('charities.create.success')) do |success, failure|
      success.html do
        if params[:charity][:plan] == 'paid'
          return redirect_to "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=8HDK7F2UPF38W&custom=Charity<#{@charity.id}>&notify_url=#{paypal_url}"
        else
          return redirect_to charity_by_slug_path(@charity.permalink)
        end
      end
      failure.html do
        flash[:notice] = t('flash.required_fields')
        render action: 'new'
      end
    end
  end
  
  def update
    update! do |success, failure|
      success.html do 
        if params[:charity][:plan] == "paid" and !@charity.subscribed
          return redirect_to "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=8HDK7F2UPF38W&custom=Charity<#{@charity.id}>&notify_url=#{paypal_url}"
        elsif params[:charity][:plan] == "free" and @charity.subscribed
          return redirect_to "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_subscr-find&alias=5TKJEMHLBYLB6"
        else
          return redirect_to charity_by_slug_path(@charity.permalink, anchor: 'edit')
        end
      end
      failure.html{ 
        flash[:notice] = t('flash.required_fields')
        return redirect_to charity_by_slug_path(@charity.permalink) 
      }
    end
  end

  def show
    begin
      if params[:id].present?
        @charity = Charity.by_permalink(params[:id]).last
      else
        return redirect_to charity_by_slug_path(resource.permalink)
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
