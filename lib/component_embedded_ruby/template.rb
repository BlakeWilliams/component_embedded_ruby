module ComponentEmbeddedRuby
  class Template
    def initialize(content, binding = nil)
      lexer = Lexer.new(content)
      parser = Parser.new(lexer.lex)

      @parse_results = parser.parse
      @binding = binding
    end

    def to_s
      render(@parse_results)
    end

    private

    attr_reader :binding

    def render(exp)
      if component_tag?(exp)
        render_component(exp)
      else
        render_tag(exp)
      end
    end

    def render_component(exp)
      component_class(exp).new(
        exp[:attributes].reduce({}, :merge),
      ).render(
        exp[:children].map(&method(:render_tag)).join("")
      )
    end

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
          exp[:children].map(&method(:render)).join("") +
        "</#{exp[:tag]}>"
      end
    end

    def render_attributes(exp)
      exp[:attributes].map do |pair|
        key = pair[:key]
        value = pair[:value]
        value = value.is_a?(Eval) ? value.eval(binding) : value

        "#{pair[:key]}=\"#{value}\""
      end.join(" ")
    end

    def component_tag?(exp)
      !!/[[:upper:]]/.match(exp[:tag][0])
    end

    def component_class(exp)
      Object.const_get(exp[:tag])
    end
  end
end
