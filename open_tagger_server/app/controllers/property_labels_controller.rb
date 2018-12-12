class PropertyLabelsController < ApplicationController
  before_action :set_property_label, only: [:show, :edit, :update, :destroy]

  # GET /property_labels
  def index
    @property_labels = PropertyLabel.all
  end

  # GET /property_labels/1
  def show
  end

  # GET /property_labels/new
  def new
    @property_label = PropertyLabel.new
  end

  # GET /property_labels/1/edit
  def edit
  end

  # POST /property_labels
  def create
    @property_label = PropertyLabel.new(property_label_params)

    if @property_label.save
      redirect_to @property_label, notice: 'Property label was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /property_labels/1
  def update
    if @property_label.update(property_label_params)
      redirect_to @property_label, notice: 'Property label was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /property_labels/1
  def destroy
    @property_label.destroy
    redirect_to property_labels_url, notice: 'Property label was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_property_label
      @property_label = PropertyLabel.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def property_label_params
      params.fetch(:property_label, {})
    end
end
