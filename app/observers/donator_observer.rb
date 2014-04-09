class DonatorObserver < ActiveRecord::Observer
  observe :donator

  def before_save(donator)
      user = User.find(donator.user_id)
      project = Project.find(donator.project_id)

      Notification.create_notification_once(:confirm_donator,
        user,
        {donator_id: donator.id},
        donator: donator,
        project: project,
        user: user)
  end


end
