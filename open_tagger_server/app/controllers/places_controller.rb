class PlacesController < ApplicationController
  before_action :set_place, only: [:show, :edit, :update, :destroy]

  # GET /places
  def index
    if params[:query].nil?
      render json: Place.all
    elsif params[:query].present?
      render json: Place.search_by_title(params[:query])
    end
  end

  # GET /places/1
  def show
  end

  # GET /places/new
  def new
    @place = Place.new
  end

  # GET /places/1/edit
  def edit
  end

  # POST /places
  def create
    @place = Place.find_or_create_by(place_params)
    if @place.save
      response = render json: @place, status: :created, location: "//places/#{@place.id}"
      return response
    else
      render json: @place.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /places/1
  def update
    if @place.update(place_params)
      redirect_to @place, notice: 'Place was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /places/1
  def destroy
    @place.destroy
    redirect_to places_url, notice: 'Place was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_place
      @place = Place.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def place_params
      ActiveModelSerializers::Deserialization
          .jsonapi_parse(
            params, only: [
              :title_en,
              :native_label,
              :wikidata_id
            ]
      )
    end
end
