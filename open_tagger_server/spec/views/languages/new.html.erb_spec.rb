require 'rails_helper'

RSpec.describe "languages/new", type: :view do
  before(:each) do
    assign(:language, Language.new())
  end

  it "renders new language form" do
    render

    assert_select "form[action=?][method=?]", languages_path, "post" do
    end
  end
end
