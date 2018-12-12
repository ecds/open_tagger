require 'rails_helper'

RSpec.describe "literals/show", type: :view do
  before(:each) do
    @literal = assign(:literal, Literal.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
