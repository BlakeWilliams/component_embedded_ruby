require "component_embedded_ruby/version"
require "component_embedded_ruby/input_reader"
require "component_embedded_ruby/lexer"
require "component_embedded_ruby/parser"
require "component_embedded_ruby/eval"
require "component_embedded_ruby/node"
require "component_embedded_ruby/renderer"
require "component_embedded_ruby/unexpected_token_error"

module ComponentEmbeddedRuby
  class Error < StandardError; end

  def self.render(content, binding: TOPLEVEL_BINDING)
    Renderer.new(
      Parser.new(
        Lexer.new(content).lex
      ).parse
    ).to_s(binding: binding)
  end

  def self.to_source(content, binding: TOPLEVEL_BINDING)
    Renderer.new(
      Parser.new(
        Lexer.new(content).lex
      ).parse
    ).to_ruby
  end
end
