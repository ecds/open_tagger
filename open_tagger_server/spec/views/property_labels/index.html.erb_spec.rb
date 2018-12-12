require 'rails_helper'

RSpec.describe "property_labels/index", type: :view do
  before(:each) do
    assign(:property_labels, [
      PropertyLabel.create!(),
      PropertyLabel.create!()
    ])
  end

  it "renders a list of property_labels" do
    render
  end
end
