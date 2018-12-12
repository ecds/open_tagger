require 'rails_helper'

RSpec.describe "property_labels/edit", type: :view do
  before(:each) do
    @property_label = assign(:property_label, PropertyLabel.create!())
  end

  it "renders the edit property_label form" do
    render

    assert_select "form[action=?][method=?]", property_label_path(@property_label), "post" do
    end
  end
end
