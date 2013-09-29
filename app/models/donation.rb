class Donation < ActiveRecord::Base
include Rails.application.routes.url_helpers
Rails.application.routes.default_url_options = { :host => 'http://catarse-charity-demo.herokuapp.com/' }
  belongs_to :users
  belongs_to :charities
  attr_accessible :amount, :comment, :status, :anonymous

  def payment(charity,amount)
  	@merchant = "daoud@daoud.com"
  	pay_request = PaypalAdaptive::Request.new
    owner = User.find(charity.user_id)
    data = {
    "returnUrl" => plansredirect2_url, 
    "requestEnvelope" => {"errorLanguage" => "en_US"},
    "currencyCode"=> charity.currency.to_s,  
    "receiverList" => receivers(owner,charity,amount),
    "cancelUrl"=> new_charity_donation_url(charity),
    "actionType"=>"PAY",
    "ipnNotificationUrl"=>paypal_url
    }
    data["feesPayer"] = "PRIMARYRECEIVER" if !owner.subscribed
    pay_response = pay_request.pay(data)
    return pay_response

   end

   def receivers(owner,charity,amount)
   	 if owner.subscribed
     	{"receiver"=>[{"email"=>charity.email.to_s, "amount"=> amount.to_s}]}
    else
    	fee = 0.05*amount
    	{"receiver"=>[{"email"=>charity.email.to_s, "amount"=> amount.to_s, "primary" => true},
    								 {"email"=> @merchant, "amount"=>fee}
    		]}
    end
   	end
end
