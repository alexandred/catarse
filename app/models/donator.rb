class Donator < ActiveRecord::Base
  schema_associations
include Rails.application.routes.url_helpers
Rails.application.routes.default_url_options = { :host => 'lillah.org' } #Configuration[:base_domain] || request.domain }
  belongs_to :users
  belongs_to :projects
  attr_accessible :amount, :comment, :status, :anonymous
  validates_presence_of :amount, :project_id
  validates_numericality_of :amount, greater_than: 0.00

  def payment(project,donator,user_id)
    @merchant = ::Configuration[:paypal_email]
    amount = donator.amount
    begin
    pay_request = PaypalAdaptive::Request.new
    data = {
    "returnUrl" => return_project_donators_url(project.id) + "?project_id=#{project.id}&amt=#{amount}", 
    "requestEnvelope" => {"errorLanguage" => "en_US"},
    "currencyCode"=> project.currency.to_s,  
    "receiverList" => receivers(project,amount),
    "cancelUrl"=> new_project_donator_url(project),
    "actionType"=>"PAY",
    "ipnNotificationUrl"=> paypal3_url + "?donator_id=#{Donator.count + 1}&user_id=#{user_id}&project_id=#{project.id}&amount=#{amount}&comment=#{CGI::escape(donator.comment)}&anonymous=#{donator.anonymous}"
    }
    data["feesPayer"] = "PRIMARYRECEIVER" if !project.subscribed
    pay_response = pay_request.pay(data)
    return pay_response
    rescue => e
    puts e
    end
   end

   def receivers(project,amount)
     if project.subscribed
      {"receiver"=>[{"email"=>project.email.to_s, "amount"=> amount.to_s}]}
    else
      fee = ((::Configuration[:platform_fee].to_f)*amount).round(2)
      {"receiver"=>[{"email"=>project.email.to_s, "amount"=> amount.to_s, "primary" => true},
                     {"email"=> @merchant, "amount"=>fee}
        ]}
    end
    end
end
