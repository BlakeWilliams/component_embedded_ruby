$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "component_embedded_ruby"
require "view_component"

require "minitest/autorun"

# Fake Rails setup

require "active_model/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "view_component/engine"
require "sprockets/railtie"

module Dummy
  class Application < Rails::Application
    config.action_controller.asset_host = "http://assets.example.com"
  end
end

Dummy::Application.config.secret_key_base = "foo"

