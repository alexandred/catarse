class DonationObserver < ActiveRecord::Observer
  observe :donation

  def after_save(donation)
      user = User.find(donation.user_id)
      charity = Charity.find(donation.charity_id)

      Notification.create_notification_once(:confirm_donation,
        user,
        {donation_id: donation.id},
        donation: donation,
        charity: charity,
        user: user,
        amount: donation.amount)
  end


end
