# coding: utf-8
class CharitiesController < ApplicationController
  include ActionView::Helpers::DateHelper
  load_and_authorize_resource only: [ :new, :create, :update, :destroy ]

  inherit_resources
  respond_to :html, except: [:backers]
  respond_to :json, only: [:index, :show, :backers, :update]
  skip_before_filter :detect_locale, only: [:backers]
  
  def new
    new! do
      @title = t('charities.new.title')
    end
  end

  protected

  def resource
    @charity ||= Charity.find params[:id]
  end
end
