class DonatorObserver < ActiveRecord::Observer
  observe :donator

  def after_save(donator)
      donator2 = Donator.find(donator.id)
      user = User.find(donator2.user_id)
      project = Project.find(donator2.project_id)
      Notification.create_notification_once(:confirm_donator,
        user,
        {donator_id: donator2.id},
        donator: donator2,
        project: project,
        user: user)
  end


end
