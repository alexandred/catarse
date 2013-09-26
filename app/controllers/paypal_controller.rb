class PaypalController < ApplicationController

  protect_from_forgery :except => :paypal_ipn

  # This will be called when soemone first subscribes
  def sign_up_user(custom)
    puts '1'
    logger.info("sign_up_user (#{custom})")
  end

  # This will be called if someone cancels a payment
  def cancel_subscription(custom)
    puts '2'
    logger.info("cacnel_subscription (#{custom})")
    user = User.find(custom.to_i)
    user.subscribed = false
    user.save
    puts '3'
  end

  # This will be called if a subscription expires
  def subscription_expired(custom)
    puts '4'
    logger.info("subscription_expired (#{custom})")
    user = User.find(custom.to_i)
    user.subscribed = false
    user.save
    puts '5'
  end

  # Called if a subscription fails
  def subscription_failed(custom)
    puts '6'
    logger.info("subscription_failed (#{custom})")
    user = User.find(custom.to_i)
    user.subscribed = false
    user.save
    puts '7'
  end

  # Called each time paypal collects a payment
  def subscription_payment(custom, plan_id)
    puts '8'
    logger.info("recurrent_payment_received (#{custom})")
    user = User.find(custom.to_i)
    user.subscribed = true
    user.save
    puts '9'
  end

  # process the PayPal IPN POST
  def paypal_ipn
puts '10'
    # use the POSTed information to create a call back URL to PayPal
    query = 'cmd=_notify-validate'
    request.params.each_pair {|key, value| query = query + '&' + key + '=' + 
      value if key != 'register/pay_pal_ipn.html/pay_pal_ipn' }
puts '11'
    #paypal_url = 'www.paypal.com'
    #if ENV['RAILS_ENV'] == 'development'
      paypal_url = 'www.sandbox.paypal.com'
    #end
puts '12'
    # Verify all this with paypal
    http = Net::HTTP.start(paypal_url, 80)
    response = http.post('/cgi-bin/webscr', query)
    http.finish
'puts 13'
    item_name = params[:item_name]
    item_number = params[:item_number]
    payment_status = params[:payment_status]
    txn_type = params[:txn_type]
    custom = params[:custom]
puts '14'
    # Paypal confirms so lets process.
    if response && response.body.chomp == 'VERIFIED' 
'puts 15'
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