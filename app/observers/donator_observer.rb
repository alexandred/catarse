class DonatorObserver < ActiveRecord::Observer
  observe :donator

  def after_save(donator)
      Notification.create_notification_once(:confirm_donator,
        user,
        {donator_id: donator.id},
        donator: donator,
        project: donator,
        user: donator)
  end


end
