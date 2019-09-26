# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Pagy::Backend
  before_action :set_items, only: [:index]

  private

    def set_items
      @items = params.has_key?('items') ? params[:items].to_i : 25
    end
end
