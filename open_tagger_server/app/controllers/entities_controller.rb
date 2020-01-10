class EntitiesController < ApplicationController
  before_action :set_entity, only: [:show, :update] #, :edit, :update, :destroy]
  before_action :set_serializer, only: [:index, :show]

  # GET /entities
  def index
    entities = Entity.where(nil)
    if params[:type].present?
      params[:entity_type] = params[:type]
    end
    if params[:entity_type].present?
      params[:entity_type] = params[:entity_type].underscore
    end
    if params.empty?
      entities = Entity.all
    elsif params[:query].present? && params[:type].present?
      if params[:query] == 'unknown'
        entities = [Entity.find_or_create_by(label: params[:query], entity_type: EntityType.find_by(label: params[:type]))]
      else
        entities = Entity.search_by_label(params[:query]).by_type(params[:type])
      end
    elsif params[:label].present? && params[:entity_type].present?
      entities = Entity.by_type(params[:entity_type]).get_by_label(params[:label])
    elsif params[:search]
      entities = Entity.search(params[:search], { size: 100 }).records
      if params[:entity_type]
        entities = entities.where(entity_type: EntityType.find_by(label: params[:entity_type]))
      end
      # paginate entities, per_page: @items, each_serializer: SearchableEntitiesSerializer
      render json: entities, each_erializer: @serializer #SearchableEntitiesSerializer
      return
    elsif params[:entity_type].present?
      entities = Entity.by_type(params[:entity_type])
    end
    
    if @public_only
      entities = entities.is_public?
    end

    paginate entities, per_page: @items, each_serializer: @serializer
  end

  def search
    paginate Entity.search_by_label(params[:query]).by_type(params[:type]), per_page: @items, each_serializer: @serializer
  end

  # GET /entities/1
  def show
    render json: @entity, location: "/entities/#{@entity.id}", serializer: @serializer
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
                :properties,
                :letters,
                :flagged
              ]
        )
    end

    def set_serializer
      if @public_only
        @serializer = EntityPublicSerializer
      else
        @serializer = EntitySerializer
      end
    end
end