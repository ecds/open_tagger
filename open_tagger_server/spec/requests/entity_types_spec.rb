require 'rails_helper'

RSpec.describe "EntityTypes", type: :request do
  describe "GET /entity_types" do
    it "works! (now write some real specs)" do
      get entity_types_path
      expect(response).to have_http_status(200)
    end
  end
end
