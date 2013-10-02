# coding: utf-8
require 'state_machine'
class Charity < ActiveRecord::Base
  extend CatarseAutoHtml
  include PgSearch
  attr_accessor :accepted_terms
  schema_associations
  belongs_to :user
  has_many :projects, dependent: :destroy
  has_many :backers
  has_many :donations
  has_many :updates
  has_one :charity_total
  #before_destroy :delete_children
  
  mount_uploader :uploaded_image, LogoUploader
  mount_uploader :video_thumbnail, LogoUploader

  catarse_auto_html_for field: :about, video_width: 600, video_height: 403
  
  validates_acceptance_of :accepted_terms, on: :create
  validates_format_of :video_url, with: /https?:\/\/(www\.)?vimeo.com\/(\d+)/, message: I18n.t('project.video_regex_validation'), allow_blank: true
  validates_uniqueness_of :permalink
  validates_presence_of :uploaded_image

  scope :by_permalink, ->(p) { where("lower(permalink) = lower(?)", p) }
  scope :by_country, ->(country) { where(country: country) }
  scope :recommended, -> { where(recommended: true) }
  scope :not_deleted_charities, ->() { where("charities.state <> 'deleted'") }
  scope :by_id, ->(id) { where(id: id) }
  scope :user_name_contains, ->(term) { joins(:user).where("unaccent(upper(users.name)) LIKE ('%'||unaccent(upper(?))||'%')", term) }
  scope :by_state, ->(state) { where(state: state) }
  scope :order_table, ->(sort) {
    if sort == 'desc'
      order('goal desc')
    elsif sort == 'asc'
      order('goal asc')
    else
      order('created_at desc')
    end
  }
  
  pg_search_scope :pg_search, :against => [:name, :about]

  delegate :display_image, :display_video_embed_url, :currency_symbol, :currency_delimiter, :display_pledged,
           to: :decorator
  
  def self.state_names
    self.state_machine.states.map do |state|
      state.name if state.name != :deleted
    end.compact!
  end

  def self.between_created_at(start_at, ends_at)
    return scoped unless start_at.present? && ends_at.present?
    where("created_at between to_date(?, 'dd/mm/yyyy') and to_date(?, 'dd/mm/yyyy')", start_at, ends_at)
  end

  state_machine :state, initial: :draft do
    state :draft, value: 'draft'
    state :rejected, value: 'rejected'
    state :online, value: 'online'
    state :deleted, value: 'deleted'
    
    event :push_to_draft do
      transition all => :draft #NOTE: when use 'all' we can't use new hash style ;(
    end

    event :push_to_trash do
      transition [:draft, :rejected] => :deleted
    end

    event :reject do
      transition draft: :rejected
    end

    event :approve do
      transition draft: :online
    end

    after_transition draft: :online, do: :after_transition_of_draft_to_online
    after_transition draft: :rejected, do: :after_transition_of_draft_to_rejected
    after_transition any => [:failed, :successful], :do => :after_transition_of_any_to_failed_or_successful
    after_transition [:draft, :rejected] => :deleted, :do => :after_transition_of_draft_or_rejected_to_deleted
  end

  def after_transition_of_any_to_failed_or_successful
    notify_observers :sync_with_mailchimp
  end

  def after_transition_of_draft_to_online
    update_attributes({ online_date: DateTime.now })
    notify_observers :notify_owner_that_charity_is_online
  end

  def after_transition_of_draft_to_rejected
    notify_observers :notify_owner_that_charity_is_rejected
  end
  
  def after_transition_of_draft_or_rejected_to_deleted
    update_attributes({ permalink: "deleted_project_#{id}"})
  end
  
  
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

  def donations_total
    charity_total ? charity_total.donations_total: 0.0
  end

  def donators_total
    charity_total ? charity_total.donators_total: 0
  end

  private

    def delete_children
      self.projects.delete_all
    end
end
