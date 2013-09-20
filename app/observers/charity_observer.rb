class CharityObserver < ActiveRecord::Observer
  observe :charity

  def after_validation(charity)
    if charity.video_url.present? && charity.video_url_changed?
      charity.download_video_thumbnail
      charity.update_video_embed_url
    end
  end
  
  def after_create(charity)
    if (user = charity.new_draft_recipient)
      Notification.create_notification_once(charity.new_draft_charity_notification_type,
                                            user,
                                            {charity_id: charity.id},
                                            {charity: charity, charity_name: charity.name, from: charity.user.email, display_name: charity.user.display_name}
                                           )
    end

    Notification.create_notification_once(charity.new_charity_received_notification_type,
                                          charity.user,
                                          {charity_id: charity.id},
                                          {charity: charity, charity_name: charity.name})
  end
  
  def notify_owner_that_charity_is_successful(charity)
    Notification.create_notification_once(:charity_success,
      charity.user,
      {charity_id: charity.id},
      charity: charity)
  end

  def notify_owner_that_charity_is_rejected(charity)
    Notification.create_notification_once(:charity_rejected,
      charity.user,
      {charity_id: charity.id},
      charity: charity)
  end

  def notify_owner_that_charity_is_online(charity)
    Notification.create_notification_once(:charity_visible,
      charity.user,
      {charity_id: charity.id},
      charity: charity)
  end

  def sync_with_mailchimp(charity)
  end
end
