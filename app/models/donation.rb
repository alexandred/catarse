class Donation < ActiveRecord::Base
include Rails.application.routes.url_helpers
  belongs_to :users
  belongs_to :charities
  attr_accessible :amount, :comment, :status, :anonymous

  def payment(charity,amount)
  	pay_request = PaypalAdaptive::Request.new
    owner = User.find(charity.user_id)
    data = {
    "returnUrl" => plansredirect2_url, 
    "requestEnvelope" => {"errorLanguage" => "en_US"},
    "currencyCode"=> charity.currency.to_s,  
    "receiverList" => receivers(owner,amount),
    "cancelUrl"=> new_charity_donation_url(charity),
    "actionType"=>"PAY",
    "ipnNotificationUrl"=>paypal_url
    }
    data["feesPayer"] = "PRIMARYRECEIVER" if !owner.subscribed
    pay_response = pay_request.pay(data)
    return pay_response

   end

   def receivers(owner,amount)
   	 if owner.subscribed
     	{"receiver"=>[{"email"=>owner.email.to_s, "amount"=> amount.to_s}]}
    else
    	fee = 0.05*amount
    	remaining = amount-fee
    	{"receiver"=>[{"email"=>owner.email.to_s, "amount"=> remaining.to_s, "primary" => true},
    								 {"email"=>"daoud@daoud.com", "amount"=>fee.to_s}
    		]}
    end
   	end
end
