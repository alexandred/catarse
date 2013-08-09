class Charity < ActiveRecord::Base
  attr_accessor :accepted_terms

  validates_acceptance_of :accepted_terms, on: :create
  validates :video_url, presence: true, if: ->(p) { p.state_name == 'online' }
  validates_format_of :video_url, with: /https?:\/\/(www\.)?vimeo.com\/(\d+)/, message: I18n.t('project.video_regex_validation'), allow_blank: true
end
