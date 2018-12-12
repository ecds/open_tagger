require "rails_helper"

RSpec.describe EntityTypesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/entity_types").to route_to("entity_types#index")
    end

    it "routes to #new" do
      expect(:get => "/entity_types/new").to route_to("entity_types#new")
    end

    it "routes to #show" do
      expect(:get => "/entity_types/1").to route_to("entity_types#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/entity_types/1/edit").to route_to("entity_types#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/entity_types").to route_to("entity_types#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/entity_types/1").to route_to("entity_types#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/entity_types/1").to route_to("entity_types#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/entity_types/1").to route_to("entity_types#destroy", :id => "1")
    end

  end
end
