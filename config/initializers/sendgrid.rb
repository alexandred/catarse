begin
  if Rails.env.production?
    ActionMailer::Base.smtp_settings = {
    address: 'smtp.mandrillapp.com',
    port: '587',
    authentication: :plain,
    user_name: "admin@lillah.org",
    password: "WQZzgYnLBPHbjej4hsn1Ow",
    domain: 'mandrillapp.com'
    }
    ActionMailer::Base.delivery_method = :smtp
  end
rescue
  nil
end
