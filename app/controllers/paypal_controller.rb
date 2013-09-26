class PaypalController < ApplicationController

  def sign_up_user(custom)
    logger.info("sign_up_user (#{custom})")
  end

  # This will be called if someone cancels a payment
  def cancel_subscription(custom)
    logger.info("cacnel_subscription (#{custom})")
    user = User.find(custom.to_i)
    user.subscribed = false
    user.save(validate: false)
  end

  # This will be called if a subscription expires
  def subscription_expired(custom)
    logger.info("subscription_expired (#{custom})")
    user = User.find(custom.to_i)
    user.subscribed = false
    user.save(validate: false)
  end

  # Called if a subscription fails
  def subscription_failed(custom)
    logger.info("subscription_failed (#{custom})")
    user = User.find(custom.to_i)
    user.subscribed = false
    user.save(validate: false)
  end

  # Called each time paypal collects a payment
  def subscription_payment(custom, plan_id)
    logger.info("recurrent_payment_received (#{custom})")
    user = User.find(custom.to_i)
    user.subscribed = true
    user.save(validate: false)
  end

  protect_from_forgery :except => :paypal_ipn

  # process the PayPal IPN POST
  def paypal_ipn
    # use the POSTed information to create a call back URL to PayPal
    query = 'cmd=_notify-validate'
    request.params.each_pair {|key, value| query = query + '&' + key + '=' + 
      value if key != 'register/pay_pal_ipn.html/pay_pal_ipn' }
    #paypal_url = 'www.paypal.com'
    #if ENV['RAILS_ENV'] == 'development'
      paypal_url = 'www.sandbox.paypal.com'
    #end
    # Verify all this with paypal
    http = Net::HTTP.start(paypal_url, 443)
    http.use_ssl = true
    response = http.post('/cgi-bin/webscr', query)
    http.finish

    item_name = params[:item_name]
    item_number = params[:item_number]
    payment_status = params[:payment_status]
    txn_type = params[:txn_type]
    custom = params[:custom]
    logger.info("#{response.body.chomp}")
    # Paypal confirms so lets process.
    if response && response.body.chomp == 'VERIFIED' 

      if txn_type == 'subscr_signup'
        sign_up_user(custom)
      elsif txn_type == 'subscr_cancel'
        cancel_subscription(custom)
      elsif txn_type == 'subscr_eot'
        subscription_expired(custom)
      elsif txn_type == 'subscr_failed'
        subscription_failed(custom)
      elsif txn_type == 'subscr_payment' && payment_status == 'Completed'
        subscription_payment(custom)
      end

      render :text => 'OK'

    else
      render :text => 'ERROR'
    end
  end
end