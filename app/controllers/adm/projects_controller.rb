class Adm::ProjectsController < Adm::BaseController
  menu I18n.t("adm.projects.index.menu") => Rails.application.routes.url_helpers.adm_projects_path

  has_scope :by_id, :pg_search, :user_name_contains, :by_state
  has_scope :between_created_at, using: [ :start_at, :ends_at ], allow_blank: true
  has_scope :order_table, default: 'created_at'

  before_filter do
    @total_projects = Project.count
  end

  [:approve, :reject, :push_to_draft].each do |name|
    define_method name do
      @project = Project.find params[:id]
      @project.send("#{name.to_s}!")
      redirect_to :back
    end
  end

  def destroy
    @project = Project.find params[:id]
    @project.destroy
    redirect_to adm_projects_path
  end

  def set_paypal_email
  conf = ::Configuration.find_or_initialize_by_name :paypal_email
   conf.update_attributes({
     value: params[:paypal_email]
   })
  conf = ::Configuration.find_or_initialize_by_name :platform_fee
   conf.update_attributes({
     value: params[:platform_fee]
   })
  conf = ::Configuration.find_or_initialize_by_name :subscription_fee
   conf.update_attributes({
     value: params[:subscription_fee]
   })
    redirect_to adm_projects_path
  end
  def collection
    @projects = end_of_association_chain.not_deleted_projects.page(params[:page])
  end
end
