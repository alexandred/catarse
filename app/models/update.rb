class Update < ActiveRecord::Base
  extend CatarseAutoHtml

  schema_associations
  belongs_to :project
  belongs_to :charity
  has_many :notifications, dependent: :destroy
  validates_presence_of :user_id, :comment, :comment_html
  before_save -> {self.comment = comment.gsub(/^\s+/, "")}

  catarse_auto_html_for field: :comment, video_width: 560, video_height: 340

  def email_comment_html
    auto_html(comment) do
      html_escape map: {
        '&' => '&amp;',
        '>' => '&gt;',
        '<' => '&lt;',
        '"' => '"'
      }
      email_image width: 513
      redcloth target: :_blank
      link target: :_blank
    end
  end
=begin
  def notify_backers
    project.subscribed_users.each do |user|
      Rails.logger.info "[User #{user.id}] - Creating notification for #{user.name}"
      Notification.create_notification_once :updates, user,
        {update_id: self.id, user_id: user.id},
        project_name: project.name.force_encoding("UTF-8"),
        project_owner: project.user.display_name.force_encoding("UTF-8"),
        project_owner_email: project.user.email.force_encoding("UTF-8"),
        from: project.user.email.force_encoding("UTF-8"),
        display_name: project.user.display_name.force_encoding("UTF-8"),
        update_title: title.force_encoding("UTF-8"),
        update: self,
        from: project.user.email.force_encoding("UTF-8"),
        display_name: project.user.display_name.force_encoding("UTF-8"),
        update_comment: email_comment_html.force_encoding("UTF-8")
    end
  end
=end 
def notify_backers
    charity.subscribed_users.each do |user|
      Rails.logger.info "[User #{user.id}] - Creating notification for #{user.name}"
      Notification.create_notification_once :updates, user,
        {update_id: self.id, user_id: user.id},
        charity_name: charity.name.force_encoding("UTF-8"),
        charity_owner: charity.user.display_name.force_encoding("UTF-8"),
        charity_owner_email: charity.user.email.force_encoding("UTF-8"),
        from: charity.user.email.force_encoding("UTF-8"),
        display_name: charity.user.display_name.force_encoding("UTF-8"),
        update_title: title.force_encoding("UTF-8"),
        update: self,
        from: charity.user.email.force_encoding("UTF-8"),
        display_name: charity.user.display_name.force_encoding("UTF-8"),
        update_comment: email_comment_html.force_encoding("UTF-8")
    end
  end
end
