# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Pagy::Backend
  before_action :set_items, only: [:index]
  before_action :public_only
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

    def public_only
      if ['http://ot.ecdsdev.org', 'http://localhost:4200'].include? request.headers['HTTP_ORIGIN']
        @public_only = false
      else
        @public_only = true
      end
    end

    def record_not_found
      render json: { error: 'record not found', status: '404' }, status: 404
    end

    def set_items
      @items = params.has_key?('items') ? params[:items].to_i : 25
    end
end
