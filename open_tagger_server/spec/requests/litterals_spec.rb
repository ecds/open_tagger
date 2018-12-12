require 'rails_helper'

RSpec.describe "Literals", type: :request do
  describe "GET /literals" do
    it "works! (now write some real specs)" do
      get literals_path
      expect(response).to have_http_status(200)
    end
  end
end
