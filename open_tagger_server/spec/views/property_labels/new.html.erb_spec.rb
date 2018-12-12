require 'rails_helper'

RSpec.describe "property_labels/new", type: :view do
  before(:each) do
    assign(:property_label, PropertyLabel.new())
  end

  it "renders new property_label form" do
    render

    assert_select "form[action=?][method=?]", property_labels_path, "post" do
    end
  end
end
