class EntitiesController < ApplicationController
  before_action :set_entity, only: [:show, :update, :destroy] #, :edit, :update, :destroy]
  before_action :set_serializer, only: [:index, :show, :search, :test_search]

  # GET /entities
  def index
    if params[:search]
      params[:query] = params[:search]
      entities = execute_search(params)
      render json: entities, meta: json_pagination(entities, params), each_serializer: EntitySearchSerializer
      return
    end
    entities = Entity.where(nil)
    if params[:type].present?
	    params[:entity_type] = params[:type].downcase.underscore
      #params[:type] = params[:type].downcase
    end
    if params[:entity_type].present?
	    params[:entity_type] = params[:entity_type].underscore.downcase
    end
    if params.empty?
      entities = Entity.all
    elsif params[:query].present? && params[:type].present?
      if params[:query] == 'unknown'
        entities = [Entity.find_or_create_by(label: params[:query], entity_type: EntityType.find_by(label: params[:type]))]
      else
	      entities = Entity.search_by_label(params[:query]).by_type(params[:type].downcase)
      end
    elsif params[:label].present? && params[:entity_type].present?
      entities = Entity.by_type(params[:entity_type]).get_by_label(params[:label])
      render json: entities.where.not(legacy_pk: 88888888), each_erializer: @serializer #SearchableEntitiesSerializer
      return
    elsif params[:entity_type].present?
      entities = Entity.by_type(params[:entity_type])
    end

    if @public_only
      entities = entities.is_public?
    end

    paginate entities.where.not(legacy_pk: 88888888), per_page: @items, each_serializer: @serializer
  end

  # def search
  #   entities = Entity.where.not(legacy_pk: 88888888).search_by_label(params[:query]).by_type(params[:type].downcase.underscore)
  #   if @public_only
  #     entities = entities.is_public?
  #   end
  #   paginate entities, per_page: @items, each_serializer: @serializer
  # end

  def search
    entities = self.execute_search(params)
    render json: entities, meta: json_pagination(entities, params), each_serializer: EntitySearchSerializer
  end

  # GET /entities/1
  def show
    if @public_only
      unless @entity.is_public?
        render json: { error: 'record not found', status: '404' }, status: 404
	      return
      end
    end
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
    # redirect_to entities_url, notice: 'Entity was successfully destroyed.'
    render json: { message: 'deleted' }, location: "/entities/#{@entity.id}"
  end

  def execute_search(params)
    if params[:type].present?
      params[:entity_type] = params[:type].downcase.underscore
    end
    page = params[:page] || 1
    items = params[:items] || 50
    # if params[:page]
    #   page = params[:page][:number] || page
    #   items = params[:page][:size] || items
    # end
    # where = {
    #   legacy_pk: { _not: 88888888 }
    # }
    where = {}
    where[:e_type] = params[:entity_type] if params[:entity_type]
    where[:is_public] = true if @public_only
    Entity.search(
      params[:query],
      # fields: [{label: :exact}, 'description'],
      boost_where: { label: params[:query] },
      where: where,
      page: page,
      per_page: items
    )
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

    def json_pagination(objects, params)
      query = "query=#{params[:query]}"
      query += "&entity_type=#{params[:entity_type]}" if params[:entity_type]
      links = {
        first: "/test?#{query}&page=1&items=#{objects.per_page}",
        last: "/test?#{query}&page=#{objects.total_pages}&items=#{objects.per_page}}"
      }
      links[:prev] = "/test?#{query}&page=#{objects.previous_page}&items=#{objects.per_page}}" if objects.previous_page
      links[:next] = "/test?#{query}&page=#{objects.next_page}&items=#{objects.per_page}}" if objects.next_page
      {
        pagination: {
          links: links,
          'per-page': objects.per_page,
          'total-objects': objects.total_count,
          'total-pages': objects.total_pages
        }
      }
    end
end