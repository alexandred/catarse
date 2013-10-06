class Donator < ActiveRecord::Base
include Rails.application.routes.url_helpers
Rails.application.routes.default_url_options = { :host => Configuration[:base_domain] || request.domain }
  belongs_to :users
  belongs_to :projects
  attr_accessible :amount, :comment, :status, :anonymous
  validates_presence_of :amount, :user_id, :project_id
  validates_numericality_of :amount, greater_than: 0.00

  def payment(project,donator,user_id)
    @merchant = "daoud@daoud.com"
    amount = donator.amount
    pay_request = PaypalAdaptive::Request.new
    owner = User.find(project.user_id)
    data = {
    "returnUrl" => return_project_donators_url(project.id) + "?project_id=#{project.id}&amt=#{amount}", 
    "requestEnvelope" => {"errorLanguage" => "en_US"},
    "currencyCode"=> project.currency.to_s,  
    "receiverList" => receivers(owner,project,amount),
    "cancelUrl"=> new_project_donator_url(project),
    "actionType"=>"PAY",
    "ipnNotificationUrl"=> paypal3_url + "?donator_id=#{Donator.count + 1}&user_id=#{user_id}&project_id=#{project.id}&amount=#{amount}&comment=#{CGI::escape(donator.comment)}&anonymous=#{donator.anonymous}"
    }
    data["feesPayer"] = "PRIMARYRECEIVER" if !owner.subscribed
    pay_response = pay_request.pay(data)
    return pay_response

   end

   def receivers(owner,project,amount)
     if owner.subscribed
      {"receiver"=>[{"email"=>owner.email.to_s, "amount"=> amount.to_s}]}
    else
      fee = (0.05*amount).round(2)
      {"receiver"=>[{"email"=>owner.email.to_s, "amount"=> amount.to_s, "primary" => true},
                     {"email"=> @merchant, "amount"=>fee}
        ]}
    end
    end
end