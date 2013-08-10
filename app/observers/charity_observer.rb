class CharityObserver < ActiveRecord::Observer
  observe :charity

  def after_validation(charity)
    if charity.video_url.present? && charity.video_url_changed?
      charity.download_video_thumbnail
      charity.update_video_embed_url
    end
  end
end
