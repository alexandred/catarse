class RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
  	if session[:plan] == "paid"
  		"https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=8HDK7F2UPF38W&custom=#{current_user.id}&notify_url=#{paypal_url}"
    else
    	root_path
    end
  end

end