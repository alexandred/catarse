class DonatorObserver < ActiveRecord::Observer
  observe :donator
  def after_save(donator)
      user = User.find(donator.user_id)
      Notification.create_notification_once(:confirm_donator,
        user,
        {donator_id: donator.id},
        donator: donator,
        project: donator,
        user: user)
  end


end
