class DonationObserver < ActiveRecord::Observer
  observe :donation

  def after_save(donation)
      donation2 = Donation.find(donation.id)
      user = User.find(donation2.user_id)
      charity = Charity.find(donation2.charity_id)

      Notification.create_notification_once(:confirm_donation,
        user,
        {donation_id: donation2.id},
        donation: donation2,
        project: charity,
        user: user)
  end


end
