# coding: utf-8

[
  { pt: 'Arte', en: 'Accidents' },
  { pt: 'Artes plásticas', en: 'Children' },
  { pt: 'Comunidade', en: 'Community' },
  { pt: 'Humor', en: 'Disaster Relief' },
  { pt: 'Quadrinhos', en: 'Education & Schools' },
  { pt: 'Dança', en: 'Environment' },
  { pt: 'Design', en: 'Family ' },
  { pt: 'Eventos', en: 'Food & Nutrition' },
  { pt: 'Moda', en: 'Healthcare & Illness' },
  { pt: 'Gastronomia', en: 'Income Generation' },
  { pt: 'Cinema & Vídeo', en: 'Livelihoods' },
  { pt: 'Jogos', en: 'Mosque Development' },
  { pt: 'Jornalismo', en: 'Non-Profits' },
  { pt: 'Música', en: 'Other' },
  { pt: 'Fotografia', en: 'Shelter & Construction' },
  { pt: 'Ciência e Tecnologia', en: 'Volunteer Work' },
  { pt: 'Teatro', en: 'Water & Sanitation' },
  { pt: 'Esporte', en: 'Youth Work' },
].each do |name|
   category = Category.find_or_initialize_by_name_pt name[:pt]
   category.update_attributes({
     name_en: name[:en]
   })
 end

[
  'confirm_backer','payment_slip','project_success','backer_project_successful',
  'backer_project_unsuccessful','project_received', 'project_received_channel', 'updates','project_unsuccessful',
  'project_visible','processing_payment','new_draft_project', 'new_draft_channel', 'project_rejected',
  'pending_backer_project_unsuccessful', 'project_owner_backer_confirmed', 'adm_project_deadline',
  'project_in_wainting_funds', 'credits_warning', 'backer_confirmed_after_project_was_closed', 
  'backer_canceled_after_confirmed'
].each do |name|
  NotificationType.find_or_create_by_name name
end

{
  company_name: 'Lillah',
  host: 'lillah.org',
  base_url: "http://lillah.org/blog",
  blog_url: "http://lillah.org/blog/blog",
  email_contact: 'admin@lillah.org',
  email_payments: 'admin@lillah.org',
  email_projects: 'admin@lillah.org',
  email_system: 'admin@lillah.org',
  email_no_reply: 'admin@lillah.org',
  facebook_url: "https://www.facebook.com/lillah.org",
  facebook_app_id: '591228010959262',
  twitter_username: "lillahorg",
  mailchimp_url: "http://eepurl.com/ONWbH",
  platform_fee: '0.05',
  paypal_email: 'admin@lillah.org',
  subscription_fee: '£10',
  subscription_ID: '9A4T2AZ8PKG6G',
  unsubscribe_alias: 'SGGGX43FAKKXN',
  support_forum: 'http://lillah.org/blog/forum',
  base_domain: 'lillah.org',
  uservoice_secret_gadget: 'change_this'
}.each do |name, value|
   conf = Configuration.find_or_initialize_by_name name
   conf.update_attributes({
     value: value
   })
end


Channel.find_or_create_by_name!(
  name: "Channel name",
  permalink: "sample-permalink",
  description: "Lorem Ipsum"
)


OauthProvider.find_or_create_by_name!(
  name: 'facebook',
  key: '591228010959262',
  secret: 'f95526d544f732d509316466be403934',
  path: 'facebook'
)
