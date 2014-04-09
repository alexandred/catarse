class DonationObserver < ActiveRecord::Observer
  observe :donation

  def after_save(donation)

      Notification.create_notification_once(:confirm_donation,
        user,
        {donation_id: donation.id},
        donation: donation,
        project: donation,
        user: donation)
  end


end
