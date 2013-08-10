class Charity < ActiveRecord::Base
  extend CatarseAutoHtml
  attr_accessor :accepted_terms
  schema_associations
  belongs_to :user
  has_many :projects
  has_many :backers
  
  mount_uploader :uploaded_image, LogoUploader
  mount_uploader :video_thumbnail, LogoUploader

  catarse_auto_html_for field: :about, video_width: 600, video_height: 403
  
  validates_acceptance_of :accepted_terms, on: :create
  validates_format_of :video_url, with: /https?:\/\/(www\.)?vimeo.com\/(\d+)/, message: I18n.t('project.video_regex_validation'), allow_blank: true

  scope :by_permalink, ->(p) { where("lower(permalink) = lower(?)", p) }

  delegate :display_image, :display_video_embed_url, :currency_symbol, :currency_delimiter,
           to: :decorator
  
  def decorator
    @decorator ||= CharityDecorator.new(self)
  end
  
  def video
    @video ||= VideoInfo.get(self.video_url) if self.video_url.present?
  end

  def update_video_embed_url
    self.video_embed_url = self.video.embed_url if self.video.present?
  end

  def download_video_thumbnail
    self.video_thumbnail = open(self.video.thumbnail_large) if self.video_url.present? && self.video
  rescue OpenURI::HTTPError => e
    Rails.logger.info "-----> #{e.inspect}"
  rescue TypeError => e
    Rails.logger.info "-----> #{e.inspect}"
  end
end
