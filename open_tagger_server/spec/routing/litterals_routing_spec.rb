require "rails_helper"

RSpec.describe LiteralsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/literals").to route_to("literals#index")
    end

    it "routes to #new" do
      expect(:get => "/literals/new").to route_to("literals#new")
    end

    it "routes to #show" do
      expect(:get => "/literals/1").to route_to("literals#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/literals/1/edit").to route_to("literals#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/literals").to route_to("literals#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/literals/1").to route_to("literals#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/literals/1").to route_to("literals#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/literals/1").to route_to("literals#destroy", :id => "1")
    end

  end
end
