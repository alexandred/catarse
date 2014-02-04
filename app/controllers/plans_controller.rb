class PlansController < ApplicationController

  def index
  end

  def redirect
  		flash[:notice] = t('flash.thanks_message')
      redirect_to user_path(current_user, anchor: "projects")
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
    elsif params.has_key?(:cm)
      case params[:cm]
        when /Charity<(.*)>/
          redirect_to charity_by_slug_path(permalink: Charity.find($1).permalink )
        when /Project<(.*)>/
          redirect_to project_by_slug_path(permalink: Project.find($1).permalink )
      end
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
