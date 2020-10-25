require "component_embedded_ruby/parser/base"
require "component_embedded_ruby/parser/root_parser"
require "component_embedded_ruby/parser/attribute_parser"
require "component_embedded_ruby/parser/tag_parser"
require "component_embedded_ruby/parser/token_reader"

module ComponentEmbeddedRuby
  class Parser
    def initialize(tokens)
      @token_reader = TokenReader.new(tokens)
    end

    def parse(inside_tag: false)
      RootParser.new(@token_reader).parse(inside_tag: inside_tag)
    end
  end
end
