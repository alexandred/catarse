class Adm::CharitiesController < Adm::BaseController
  before_filter do
    @total_charities = Charity.count
  end

  def collection
    @charities = end_of_association_chain.not_deleted_charities.page(params[:page])
  end
end
