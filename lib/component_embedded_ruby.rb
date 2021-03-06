# frozen_string_literal: true

require "component_embedded_ruby/version"
require "component_embedded_ruby/lexer"
require "component_embedded_ruby/parser"
require "component_embedded_ruby/eval"
require "component_embedded_ruby/node"
require "component_embedded_ruby/compiler"
require "component_embedded_ruby/template"
require "component_embedded_ruby/unexpected_token_error"

# Rails support
require "component_embedded_ruby/rails_handler" if defined?(Rails::Railtie)

module ComponentEmbeddedRuby
  class Error < StandardError; end
end
