class UpdatesController < ApplicationController
  inherit_resources
  load_and_authorize_resource

  actions :index, :create, :destroy
  respond_to :html, only: [ :index, :create, :destroy ]
  belongs_to :project, :charity, :optional => true

  def index
    index! do |format|
      format.html{ return render :index, layout: false } if @project
      format.html { redirect_to controller: 'charities', action: 'show', id: parent.id } if @charity
    end
  end

  def create
    @update = parent.updates.new(params[:update])
    @update.user = current_user
    Rails.logger.info @update.valid?
    Rails.logger.info @update.errors
    create! do |format|
      format.html{ return index }
    end
  end

  def destroy
    destroy!{|format| return index }
  end
end