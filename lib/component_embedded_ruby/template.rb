module ComponentEmbeddedRuby
  class Template
    def initialize(content, binding = nil)
      lexer = Lexer.new(content)
      parser = Parser.new(lexer.lex)

      @parse_results = parser.parse
      @binding = binding
    end

    def to_s
      render_tag(@parse_results)
    end

    private

    attr_reader :binding

    def render_tag(exp)
      if exp[:tag].nil?
        content = exp[:children]
        if content.is_a?(Eval)
          content.eval(binding)
        else
          content
        end
      else
        "<#{exp[:tag]} #{render_attributes(exp)}>" +
          exp[:children].map(&method(:render_tag)).join("") +
        "</#{exp[:tag]}>"
      end
    end

    def render_attributes(exp)
      exp[:attributes].map do |pair|
        key = pair[:key]
        value = pair[:value]
        value = value.is_a?(Eval) ? value.eval(binding) : valuee

        "#{pair[:key]}=\"#{value}\""
      end.join(" ")
    end
  end
end
