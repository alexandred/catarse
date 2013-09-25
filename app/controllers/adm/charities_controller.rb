class Adm::CharitiesController < Adm::BaseController

	#has_scope :by_id, :pg_search, :user_name_contains, :by_state
	#has_scope :between_created_at, using: [ :start_at, :ends_at ], allow_blank: true
	#has_scope :order_table, default: 'created_at'

	before_filter do
    	@total_charities = Charity.count
  	end

	[:approve, :reject, :push_to_draft].each do |name|
		define_method name do
			@charity = Charity.find params[:id]
			@charity.send("#{name.to_s}!")
      		redirect_to :back
    	end
  	end

  	def destroy
    	@charity = Charity.find params[:id]
    	@charity.destroy
    	redirect_to adm_charities_path
  	end

  	def collection
    	@charities = end_of_association_chain.not_deleted_charities.page(params[:page])
  	end
end
