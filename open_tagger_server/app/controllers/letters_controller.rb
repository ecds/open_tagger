# frozen_string_literal: true

# app/controllers/letters_controller.rb
class LettersController < ApplicationController
  before_action :set_params, only: [:index]
  # after_action { pagy_headers_merge(@pagy) if @pagy }
  # authorize_resource

  # GET /letters
  def index
    @letters = Letter.where(nil)
    @filter_params.each do |key, value|
      next if value.nil?
      values = value.split(',')
      @letters = @letters.public_send(key, values.shift())
      if values.present?
        values.each do |value|
          @letters = @letters.or(Letter.public_send(key, value))
        end
      end
    end
    @letters = @letters.between(@start, @end)
    paginate @letters.order('date ASC'), per_page: @items
  end

  # GET /letters/1
  def show
    @letter = Letter.find(params[:id])
    if params[:content] == true
      render json: @letter, serializer: LetterWithContentSerializer
    end
    render json: @letter#, include: []
  end

  # # POST /letters
  # TODO Somemething, maybe on the model
  # to create a a letter object if LetterAlias is
  # new. maybe however the import worked?
  def create
    @letter = Letter.find_or_create_by(letter_params)
    if @letter.save
      render json: @letter, status: :created, location: "/letters/#{@letter.id}"
    else
      render json: @letter.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /letters/1
  def update
    @letter = Letter.find(params[:id])
    if @letter.update(letter_params)
      render json: @letter, location: "/letters/#{@letter.id}"
    else
      render json: @letter.errors, status: :unprocessable_entity
    end
  end

  # # DELETE /letters/1
  # def destroy
  #   @letter.destroy
  # end

    private
      # Only allow a trusted parameter "white list" through.
      # def letter_params
      #   ActiveModelSerializers::Deserialization
      #       .jsonapi_parse(
      #         params, only: [
      #               :title, :description,
      #               :is_geo, :modes, :published, :theme_id,
      #               :mode_id, :media, :meta_description
      #           ]
      #       )
      # end
      def letter_params
        ActiveModelSerializers::Deserialization
            .jsonapi_parse(
              params, only: [
                :first,
                :last,
                :wikidata_id,
                :literals,
                :content
              ]
        )
      end

      def set_params
        @start = params[:start].present? ? Date.parse(params[:start]) : Letter.minimum('date')
        @end = params[:end].present? ? Date.parse(params[:end]) : Letter.maximum('date')
        @filter_params = params.slice(:recipients, :repositories)
      end
end
