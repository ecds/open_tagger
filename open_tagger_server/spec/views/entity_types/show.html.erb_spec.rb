require 'rails_helper'

RSpec.describe "entity_types/show", type: :view do
  before(:each) do
    @entity_type = assign(:entity_type, EntityType.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
