class ExploreController < ApplicationController

  def index
  	if params.has_key?("option")
  		redirect_to charity_search_path(params[:search]) if params[:option] == "charities"
  		redirect_to "/explore#search/" + params[:search] if params[:option] == "projects"
  	end
    @title = t('explore.title')
    @categories = Category.with_projects.order(:name_pt).all
    # Just to know if we should present the menu entries, the actual projects are fetched via AJAX
    @recommended = Project.visible.not_expired.recommended.limit(3)
    @expiring = Project.visible.expiring.limit(3)
    @recent = Project.visible.recent.not_expired.limit(3).order('created_at DESC')
    @successful = Project.visible.successful.limit(3)
  end

end
