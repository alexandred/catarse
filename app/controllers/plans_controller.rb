class PlansController < ApplicationController
	before_filter :loggedin, except: 'redirect2'

  def index
  end

  def redirect
  		session[:plan] = params[:plan]
  		redirect_to new_user_session_path(active_register: true)
  end

  def redirect2
  	if params.has_key?(:amt)
  		 flash[:notice] = "Thank you! Your payment of $#{params[:amt]} was sucessful. An invoice has been sent to your email."
  	end
  	redirect_to root_path
  end

  private
  	def loggedin
  		if current_user != nil
  			redirect_to root_path
  		end
  	end
end
