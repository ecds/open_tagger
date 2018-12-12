require 'rails_helper'

RSpec.describe "property_labels/show", type: :view do
  before(:each) do
    @property_label = assign(:property_label, PropertyLabel.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
