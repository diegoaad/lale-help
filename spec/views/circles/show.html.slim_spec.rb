require 'rails_helper'

RSpec.describe "circles/show", type: :view do
  before(:each) do
    assign(:circle, FactoryGirl.create(:circle))
  end

  it "renders attributes in <p>" do
    render
  end
end