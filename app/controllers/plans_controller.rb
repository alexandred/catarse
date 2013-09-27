class PlansController < ApplicationController
	before_filter :not_loggedin
  def index
  end

  def redirect
  	session[:plan] = params[:plan]
  	redirect_to new_user_session_path(active_register: true)
  end

  private
  	def not_loggedin
  		if current_user != nil
  			redirect_to root_path
  		end
  	end
end
