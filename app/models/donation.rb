class Donation < ActiveRecord::Base
include Rails.application.routes.url_helpers
Rails.application.routes.default_url_options = { :host => 'catarse-charity-demo.herokuapp.com' }
  belongs_to :users
  belongs_to :charities
  attr_accessible :amount, :comment, :status, :anonymous
  validates_presence_of :amount, :user_id, :charity_id
  validates_numericality_of :amount, greater_than: 0.00

  def payment(charity,donation)
  	@merchant = "daoud@daoud.com"
  	amount = donation.amount
  	pay_request = PaypalAdaptive::Request.new
    owner = User.find(charity.user_id)
    data = {
    "returnUrl" => return_charity_donations_url(charity.id) + "?charity_id=#{charity.id}&amt=#{amount}", 
    "requestEnvelope" => {"errorLanguage" => "en_US"},
    "currencyCode"=> charity.currency.to_s,  
    "receiverList" => receivers(owner,charity,amount),
    "cancelUrl"=> new_charity_donation_url(charity),
    "actionType"=>"PAY",
    "ipnNotificationUrl"=> paypal2_url + "?donation_id=#{Donation.count + 1}&user_id=#{donation.user_id}&charity_id=#{charity.id}&amount=#{amount}&comment=#{CGI::escape(donation.comment)}&anonymous=#{donation.anomymous}"
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
