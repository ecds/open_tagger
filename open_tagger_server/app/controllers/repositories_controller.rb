# frozen_string_literal: true

class RepositoriesController < ApplicationController
  before_action :set_repository, only: [:show, :update, :destroy]
  before_action :set_serializer, only: [:index, :show]
  # GET /repositories
  def index
    if @public_only
      @repositories = Repository._public
    else
      @repositories = Repository.all
    end

    render json: @repositories, each_serializer: @serializer
  end

  # GET /repositories/1
  def show
    render json: @repository, serializer: @serializer
  end

  # POST /repositories
  def create
    @repository = Repository.new(repository_params)

    if @repository.save
      render json: @repository, status: :created, location: @repository
    else
      render json: @repository.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /repositories/1
  def update
    if @repository.update(repository_params)
      render json: @repository
    else
      render json: @repository.errors, status: :unprocessable_entity
    end
  end

  # DELETE /repositories/1
  def destroy
    @repository.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_repository
      if @public_only
        @repository = Repository._public.find(params[:id])
      else
        @repository = Repository.find(params[:id])
      end
    end

    def set_serializer
      if @public_only
        @serializer = RepositoryPublicSerializer
      else
        @serializer = RepositorySerializer
      end
    end

    # Only allow a trusted parameter "white list" through.
    def repository_params
      ActiveModelSerializers::Deserialization
            .jsonapi_parse(
              params, only: [
                :label, :collections
              ]
        )
    end
end
