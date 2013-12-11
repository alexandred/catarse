class PlansController < ApplicationController
	before_filter :loggedin, except: 'redirect2'

  def index
  end

  def redirect
  		session[:plan] = params[:plan]
  		redirect_to new_user_session_path(active_register: true)
  end

  def redirect2
  	if params.has_key?(:project_id)
       flash[:notice] = t('flash.thanks_message')
       flash.keep
       redirect_to project_by_slug_path(permalink: Project.find(params[:project_id]).permalink )
  	elsif params.has_key?(:charity_id)
       flash[:notice] = t('flash.thanks_message')
       flash.keep
       redirect_to charity_by_slug_path(permalink: Charity.find(params[:charity_id]).permalink )
    else
  	 redirect_to root_path
    end
  end

  private
  	def loggedin
  		if current_user != nil
  			redirect_to root_path
  		end
  	end
end
