require 'rails_helper'

RSpec.describe "entity_types/edit", type: :view do
  before(:each) do
    @entity_type = assign(:entity_type, EntityType.create!())
  end

  it "renders the edit entity_type form" do
    render

    assert_select "form[action=?][method=?]", entity_type_path(@entity_type), "post" do
    end
  end
end
