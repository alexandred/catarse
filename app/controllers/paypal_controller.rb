class PaypalController < ApplicationController
  require 'bigdecimal'
  protect_from_forgery :except => [:paypal_ipn, :ipn2, :ipn3]

  def sign_up_user(custom)
    logger.info("sign_up_user (#{custom})")
  end

  # This will be called if someone cancels a payment
  def cancel_subscription(custom)
    case custom
      when /(.*)<(.*)>/
        logger.info("cacnel_subscription (#{custom})")
        model = $1.constantize.find($2.to_i)
        model.subscribed = false
        model.save(validate: false)
    end
  end

  # This will be called if a subscription expires
  def subscription_expired(custom)
    case custom
      when /(Charity|Project)<\d+>/
        logger.info("expired_subscription (#{custom})")
        model = $1.constantize.find($2.to_i)
        model.subscribed = false
        model.save(validate: false)
    end
  end

  # Called if a subscription fails
  def subscription_failed(custom)
    case custom
      when /(Charity|Project)<\d+>/
        logger.info("failed_subscription (#{custom})")
        model = $1.constantize.find($2.to_i)
        model.subscribed = false
        model.save(validate: false)
    end
  end

  # Called each time paypal collects a payment
  def subscription_payment(custom)
    case custom
      when /(Charity|Project)<\d+>/
        logger.info("success_subscription (#{custom})")
        model = $1.constantize.find($2.to_i)
        model.subscribed = true
        model.save(validate: false)
    end
  end

  def new_charity_donation(params)
    donation = Donation.new
    donation.id = params["donation_id"]
    donation.user_id = params["user_id"] unless params["user_id"] == ""
    donation.charity_id = params["charity_id"]
    donation.amount = BigDecimal.new(params["amount"])
    donation.comment = CGI::unescape(params["comment"])
    if params["anonymous"] == "true"
      donation.anonymous = true
    else
      donation.anonymous = false
    end
    donation.save!
  end

  def new_project_donator(params)
    donator = Donator.new
    donator.id = params["donator_id"]
    donator.user_id = params["user_id"] unless params["user_id"] == ""
    donator.project_id = params["project_id"]
    donator.amount = BigDecimal.new(params["amount"])
    donator.comment = CGI::unescape(params["comment"])
    if params["anonymous"] == "true"
      donator.anonymous = true
    else
      donator.anonymous = false
    end
    donator.save!
  end

  # process the PayPal IPN POST
  def paypal_ipn
    # use the POSTed information to create a call back URL to PayPal
    query = 'cmd=_notify-validate'
    request.params.each_pair {|key, value| query = query + '&' + key + '=' + 
      value if key != 'register/pay_pal_ipn.html/pay_pal_ipn' }
    paypal_url = 'www.paypal.com'
    if ENV['RAILS_ENV'] == 'production'
      paypal_url = 'www.sandbox.paypal.com'
    end
    # Verify all this with paypal
    http = Net::HTTP.new(paypal_url, 443)
    http.use_ssl = true
    http.start
    response = http.post('/cgi-bin/webscr', query)
    http.finish

    item_name = params[:item_name]
    item_number = params[:item_number]
    payment_status = params[:payment_status]
    txn_type = params[:txn_type]
    custom = params[:custom]
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

  def ipn2
    params = request.params
    parametres = 'cmd=_notify-validate&' + env['rack.request.form_vars']
    paypal_url = 'www.sandbox.paypal.com'
    if ENV['RAILS_ENV'] == 'production'
    paypal_url = 'www.sandbox.paypal.com'
    end
    # Verify all this with paypal
    http = Net::HTTP.new(paypal_url, 443)
    http.use_ssl = true
    http.start
    response = http.post('/cgi-bin/webscr', parametres)
    http.finish
    if response && response.body.chomp == 'VERIFIED' 
      if params.has_key?("transaction")
        new_charity_donation(params)
      end
      print 'verified'
      render :text => 'OK'
    else
      print 'unverified'
      render :text => 'ERROR'
    end
  end

  def ipn3
    params = request.params
    parametres = 'cmd=_notify-validate&' + env['rack.request.form_vars']
    paypal_url = 'www.sandbox.paypal.com'
   # if ENV['RAILS_ENV'] == 'production'
   # paypal_url = 'www.sandbox.paypal.com'
   # end
    # Verify all this with paypal
    http = Net::HTTP.new(paypal_url, 443)
    http.use_ssl = true
    http.start
    response = http.post('/cgi-bin/webscr', parametres)
    http.finish
    if response && response.body.chomp == 'VERIFIED' 
      if params.has_key?("transaction")
        new_project_donator(params)
      end
      print 'verified'
      render :text => 'OK'
    else
      print 'unverified'
      render :text => 'ERROR'
    end
  end
end
