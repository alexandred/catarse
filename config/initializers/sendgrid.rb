begin
  if Rails.env.production?
    ActionMailer::Base.smtp_settings = {
    address: 'smtp.mandrillapp.com',
    port: '587',
    authentication: :plain,
    user_name: "admin@lillah.org",
    password: "WQZzgYnLBPHbjej4hsn1Ow",
    domain: 'lillah.org',
    :enable_starttls_auto => true,
    :openssl_verify_mode  => OpenSSL::SSL::VERIFY_NONE
    }
    ActionMailer::Base.delivery_method = :smtp
  end
rescue
  nil
end
