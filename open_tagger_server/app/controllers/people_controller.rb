# frozen_string_literal: true

# app/controllers/people_controller.rb
class PeopleController < ApplicationController
  # authorize_resource

  # GET /people
  def index
    # @people = Person.all
    if params[:query].nil?
      render json: Person.all
    elsif params[:query].present?
      render json: Person.search_by_name(params[:query])
    end
    # render json: @people, include: []
  end

  # GET /people/1
  def show
    render json: @person,
           include: []
  end

  # # POST /people
  # TODO Somemething, maybe on the model
  # to create a a person object if PersonAlias is
  # new. maybe however the import worked?
  def create
    @person = Person.find_or_create_by(person_params)
    if @person.save
      response = render json: @person, status: :created, location: "//people/#{@person.id}"
      return response
    else
      render json: @person.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /people/1
  def update
    @person = Person.find(params[:id])
    if @person.update(person_params)
      render json: @person, location: "/people/#{@person.id}"
    else
      render json: @person.errors, status: :unprocessable_entity
    end
  end

  # # DELETE /people/1
  # def destroy
  #   @person.destroy
  # end

    private
      # Only allow a trusted parameter "white list" through.
      # def person_params
      #   ActiveModelSerializers::Deserialization
      #       .jsonapi_parse(
      #         params, only: [
      #               :title, :description,
      #               :is_geo, :modes, :published, :theme_id,
      #               :mode_id, :media, :meta_description
      #           ]
      #       )
      # end
      def person_params
        ActiveModelSerializers::Deserialization
            .jsonapi_parse(
              params, only: [
                :first,
                :last,
                :wikidata_id,
                :literals
              ]
        )
      end
end
