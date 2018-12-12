require 'rails_helper'

RSpec.describe "literals/index", type: :view do
  before(:each) do
    assign(:literals, [
      Literal.create!(),
      Literal.create!()
    ])
  end

  it "renders a list of literals" do
    render
  end
end
