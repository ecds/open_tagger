require 'rails_helper'

RSpec.describe "literals/new", type: :view do
  before(:each) do
    assign(:literal, Literal.new())
  end

  it "renders new literal form" do
    render

    assert_select "form[action=?][method=?]", literals_path, "post" do
    end
  end
end
