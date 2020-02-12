class EntityTypesController < ApplicationController
  before_action :set_entity_type, only: [:show, :edit, :update, :destroy]

  # GET /entity_types
  def index
    if params[:label]
      render json: EntityType.where(label: params[:label])
    else
      render json: EntityType.all
    end
  end

  # GET /entity_types/1
  def show
  end

  # GET /entity_types/new
  def new
    @entity_type = EntityType.new
  end

  # GET /entity_types/1/edit
  def edit
  end

  # POST /entity_types
  def create
    @entity_type = EntityType.new(entity_type_params)

    if @entity_type.save
      redirect_to @entity_type, notice: 'Entity type was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /entity_types/1
  def update
    if @entity_type.update(entity_type_params)
      redirect_to @entity_type, notice: 'Entity type was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /entity_types/1
  def destroy
    @entity_type.destroy
    redirect_to entity_types_url, notice: 'Entity type was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_entity_type
      @entity_type = EntityType.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def entity_type_params
      params.fetch(:entity_type, {})
    end
end
