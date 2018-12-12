require "rails_helper"

RSpec.describe PropertyLabelsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/property_labels").to route_to("property_labels#index")
    end

    it "routes to #new" do
      expect(:get => "/property_labels/new").to route_to("property_labels#new")
    end

    it "routes to #show" do
      expect(:get => "/property_labels/1").to route_to("property_labels#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/property_labels/1/edit").to route_to("property_labels#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/property_labels").to route_to("property_labels#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/property_labels/1").to route_to("property_labels#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/property_labels/1").to route_to("property_labels#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/property_labels/1").to route_to("property_labels#destroy", :id => "1")
    end

  end
end
