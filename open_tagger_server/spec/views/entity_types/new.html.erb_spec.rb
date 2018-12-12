require 'rails_helper'

RSpec.describe "entity_types/new", type: :view do
  before(:each) do
    assign(:entity_type, EntityType.new())
  end

  it "renders new entity_type form" do
    render

    assert_select "form[action=?][method=?]", entity_types_path, "post" do
    end
  end
end
