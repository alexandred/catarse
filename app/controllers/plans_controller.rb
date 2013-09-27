class PlansController < ApplicationController
  def index
  end

  def redirect
  	session[:plan] = params[:plan]
  	redirect_to new_user_session_path(active_register: true)
  end

end
