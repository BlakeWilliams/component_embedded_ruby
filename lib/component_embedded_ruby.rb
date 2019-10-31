require "component_embedded_ruby/version"
require "component_embedded_ruby/lexer"
require "component_embedded_ruby/parser"
require "component_embedded_ruby/template"
require "component_embedded_ruby/eval"

module ComponentEmbeddedRuby
  class Error < StandardError; end

  def self.template(content, binding)
    Template.new(content, binding)
  end
end
