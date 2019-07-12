class EntitiesController < ApplicationController
  before_action :set_entity, only: [:show, :edit, :update, :destroy]

  # GET /entities
  def index
    if params.empty?
      render json: Entity.all
    elsif params[:query].present? && params[:type].present?
      if params[:query] == 'unknown'
        render json: [Entity.find_or_create_by(label: params[:query], entity_type: EntityType.find_by(label: params[:type]))]
      else
        render json: Entity.search_by_label(params[:query]).by_type(params[:type])
      end
    elsif params[:entity_type].present?
      render json: Entity.by_type(params[:entity_type])
    end
  end

  # GET /entities/1
  def show
    render json: @entity, location: "/entities/#{@entity.id}"
  end

  # GET /entities/new
  def new
    @entity = Entity.new
  end

  # GET /entities/1/edit
  def edit
  end

  # POST /entities
  def create
    @entity = Entity.new(entity_params)
    p "data!!!!!!!!! #{params[:data]}"
    @entity.entity_type = EntityType.find(params[:data][:relationships][:'entity-type'][:data][:id])

    if @entity.save!
      render json: @entity, location: "/entities/#{@entity.id}"
    else
      render json: @entity
    end
  end

  # PATCH/PUT /entities/1
  def update
    if @entity.update!(entity_params)
      render json: @entity, location: "/entities/#{@entity.id}"
    end
  end

  # DELETE /entities/1
  def destroy
    @entity.destroy
    redirect_to entities_url, notice: 'Entity was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_entity
      @entity = Entity.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def entity_params
      ActiveModelSerializers::Deserialization
            .jsonapi_parse(
              params, only: [
                :label,
                :literals,
                :suggestion,
                :entity_type,
                :'entity-type',
                :properties
              ]
        )
    end
end
