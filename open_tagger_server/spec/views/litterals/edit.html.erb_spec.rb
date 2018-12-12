require 'rails_helper'

RSpec.describe "literals/edit", type: :view do
  before(:each) do
    @literal = assign(:literal, Literal.create!())
  end

  it "renders the edit literal form" do
    render

    assert_select "form[action=?][method=?]", literal_path(@literal), "post" do
    end
  end
end
