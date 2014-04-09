class DonationObserver < ActiveRecord::Observer
  observe :donation

  def after_save(donation)
      user = User.find(donation.user_id)
      charity = Charity.find(donation.project_id)

      Notification.create_notification_once(:confirm_donation,
        user,
        {donation_id: donation.id},
        donation: donation,
        charity: project,
        user: user,
        amount: donator.amount)
  end


end