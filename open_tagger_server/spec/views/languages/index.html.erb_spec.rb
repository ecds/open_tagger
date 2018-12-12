require 'rails_helper'

RSpec.describe "languages/index", type: :view do
  before(:each) do
    assign(:languages, [
      Language.create!(),
      Language.create!()
    ])
  end

  it "renders a list of languages" do
    render
  end
end
