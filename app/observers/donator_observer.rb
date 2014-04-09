class DonatorObserver < ActiveRecord::Observer
  observe :donator

  def after_save(donator)
      user = User.find(donator.user_id)
      project = Project.find(donator.project_id)
      raise donator.inspect
      Notification.create_notification_once(:confirm_donator,
        user,
        {donator_id: donator.id},
        donator: donator,
        project: project,
        user: user)
  end


end
