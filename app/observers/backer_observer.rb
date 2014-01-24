class BackerObserver < ActiveRecord::Observer
  observe :donator, :donation

  def after_create(backer)
    backer.define_key
    backer.define_payment_method
  end

  def before_save(backer)
    #  if backer.project_id 
    #    project = Project.find(backer.project_id)
    #  else
    #    project = Charity.find(backer.charity_id)
    #  end
    #  Notification.create_notification_once(:confirm_backer,
    #    backer.user,
    #    {backer_id: backer.id},
    #    backer: backer,
    #    project_name: project.name)

    #  Notification.create_notification_once(:project_owner_backer_confirmed,
    #    backer.project.user,
    #    {backer_id: backer.id},
    #    backer: backer,
    #    project_name: project.name)

   # unless !backer.user || backer.user.have_address?
   #   backer.user.address_street = backer.address_street
   #   backer.user.address_number = backer.address_number
   #   backer.user.address_neighbourhood = backer.address_neighbourhood
   #   backer.user.address_zip_code = backer.address_zip_code
   #   backer.user.address_city = backer.address_city
   #   backer.user.address_state = backer.address_state
   #   backer.user.phone_number = backer.address_phone_number
   # end

   # unless backer.user.full_name.present?
   #   backer.user.full_name = backer.payer_name
   # end

   # backer.user.save
  end

  def after_save(backer)
    Notification.create_notification_once(:project_success,
      backer.project.user,
      {project_id: backer.project.id},
      project: backer.project) if backer.project.reached_goal?
  end

  def notify_backoffice(backer)
    CreditsMailer.request_refund_from(backer).deliver
  end

  def notify_backoffice_about_canceled(backer)
    user = User.where(email: Configuration[:email_payments]).first
    if user.present?
      Notification.create_notification_once(:backer_canceled_after_confirmed,
        user,
        {backer_id: backer.id},
        backer: backer)
    end
  end

end
