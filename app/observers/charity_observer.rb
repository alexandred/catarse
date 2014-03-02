class CharityObserver < ActiveRecord::Observer
  observe :charity

  def after_validation(charity)
    if charity.video_url.present? && charity.video_url_changed?
      charity.download_video_thumbnail
      charity.update_video_embed_url
    end
  end
  
  def after_create(charity)
    Notification.create_notification_once(:charity_received,
                                          charity.user,
                                          {charity_id: charity.id},
                                          {charity: charity, charity_name: charity.name})
  end

  def notify_owner_that_charity_is_rejected(charity)
    Notification.create_notification_once(:charity_rejected,
      charity.user,
      {project_id: charity.id},
      charity: charity)
  end

  def notify_owner_that_charity_is_online(charity)
    Notification.create_notification_once(:charity_visible,
      charity.user,
      {project_id: charity.id},
      charity: charity)
  end

  def sync_with_mailchimp(charity)
  end
end
