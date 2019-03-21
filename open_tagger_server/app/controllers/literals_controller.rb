class LiteralsController < ApplicationController
  before_action :set_literal, only: [:show, :edit, :update, :destroy]

  # GET /literals?params
  def index
    @existing
    if params.nil?
      render json: Literal.all
    elsif params[:text].present? && params[:type].present?
      if params[:search]
        @existing = Literal.by_text_and_type(params[:text], params[:type])
      else
        @existing = Literal.by_text_and_type(params[:text], params[:type]).first
      end
      if @existing.present?
        render json: @existing, include: [:entity]
      else
        Literal.create(text: params[:text])
        render json: Literal.where(text: params[:text]).where(entity: nil)
      end
    end
  end

  # GET /literals/1
  def show
    render json: Literal.find_or_create_by(text: params[:text])
  end

  # GET /literals/new
  def new
    @literal = Literal.new
  end

  # GET /literals/1/edit
  def edit
  end

  # POST /literals
  def create
    @literal = Literal.new(literal_params)

    if @literal.save
      redirect_to @literal, notice: 'Literal was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /literals/1
  def update
    if @literal.update(literal_params)
      render json: @literal, location: "/literals/#{@literal.id}"
    else
      render :edit
    end
  end

  # DELETE /literals/1
  def destroy
    @literal.destroy
    # redirect_to literals_url, notice: 'Literal was successfully destroyed.'
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_literal
      @literal = Literal.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def literal_params
      ActiveModelSerializers::Deserialization
            .jsonapi_parse(
              params, only: [
                :text,
                :entity,
                :review
              ]
      )
    end
end
