require 'rails_helper'

RSpec.describe "entity_types/index", type: :view do
  before(:each) do
    assign(:entity_types, [
      EntityType.create!(),
      EntityType.create!()
    ])
  end

  it "renders a list of entity_types" do
    render
  end
end
