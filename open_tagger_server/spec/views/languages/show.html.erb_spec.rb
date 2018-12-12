require 'rails_helper'

RSpec.describe "languages/show", type: :view do
  before(:each) do
    @language = assign(:language, Language.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
