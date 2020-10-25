require "component_embedded_ruby/parser/base"
require "component_embedded_ruby/parser/root_parser"
require "component_embedded_ruby/parser/attribute_parser"
require "component_embedded_ruby/parser/tag_parser"
require "component_embedded_ruby/parser/token_reader"

module ComponentEmbeddedRuby
  module Parser
    def self.parse(tokens)
      @token_reader = TokenReader.new(tokens)

      RootParser.new(@token_reader).call
    end
  end
end
