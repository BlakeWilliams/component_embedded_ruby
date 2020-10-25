# frozen_string_literal: true

require "test_helper"

class RenderInTest < ActionDispatch::IntegrationTest
  def test_basic_crb_render
    get "/"

    assert_select "h1", text: "Hello world"
  end

  def test_crb_with_renderable
    get "/renderable"

    assert_select "div p", text: "Hello from renderable"
  end
end
