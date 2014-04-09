class DonationObserver < ActiveRecord::Observer
  observe :donation

  def before_save(donation)
      user = User.find(donation.user_id)
      charity = Charity.find(donation.charity_id)

      Notification.create_notification_once(:confirm_donation,
        user,
        {donator_id: donation.id},
        backer: donation,
        project: charity,
        user: user)
  end


end
