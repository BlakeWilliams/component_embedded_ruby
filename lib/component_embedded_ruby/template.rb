module ComponentEmbeddedRuby
  class Template
    def initialize(template)
      @template = template
    end

    def to_ruby
      tokens = Lexer.new(@template).lex
      nodes = Parser.parse(tokens)
      Compiler.new(nodes).to_ruby
    end

    def to_s(binding: TOPLEVEL_BINDING)
      eval(to_ruby, binding)
    end
  end
end
