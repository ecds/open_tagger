# frozen_string_literal: true

# app/controllers/letters_controller.rb
class LettersController < ApplicationController
  # authorize_resource

  # GET /letters
  def index
    # @letters = Letter.all
    if params[:query].nil?
      render json: Letter.all
    elsif params[:query].present?
      render json: Letter.search_by_name(params[:query])
    end
    # render json: @letters, include: []
  end

  # GET /letters/1
  def show
    @letter = Letter.find(params[:id])
    render json: @letter,
           include: []
  end

  # # POST /letters
  # TODO Somemething, maybe on the model
  # to create a a letter object if LetterAlias is
  # new. maybe however the import worked?
  def create
    @letter = Letter.find_or_create_by(letter_params)
    if @letter.save
      response = render json: @letter, status: :created, location: "/letters/#{@letter.id}"
      return response
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
end
