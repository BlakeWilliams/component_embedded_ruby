module ComponentEmbeddedRuby
  class Template
    def initialize(content)
      lexer = Lexer.new(content)
      parser = Parser.new(lexer.lex)

      @parse_results = parser.parse
      @func = "''"
    end

    def render(binding)
      binding.instance_eval(compile)
    end

    def compile
      @_compiled_template ||= begin
        render_tree(@parse_results)

        @func
      end
    end

    private

    attr_reader :binding

    def push_string(string)
      @func << "+ '#{string.gsub("'", "\\'")}'"
    end

    def push_eval(to_eval)
      @func << "+ (#{to_eval}).to_s"
    end

    def render_tree(exp)
      if component_tag?(exp)
        render_component(exp)
      else
        render_tag(exp)
      end
    end

    def render_component(exp)
      @func << " + #{component_class(exp)}.new().render({"

      @func << (exp[:attributes].map do |attr|
        key = " :\"#{attr[:key]}\" => "

        value = if attr[:value].is_a?(Eval)
          "#{attr[:value].value}"
        else
          "\"#{attr[:value]}\""
        end

        key + value
      end.join(', '))

      @func << "}, ''"

      exp[:children].map(&method(:render_tag)).join("")

      @func << ')'
    end

    def render_tag(exp)
      if exp[:tag].nil?
        content = exp[:children]

        if content.is_a?(Eval)
          push_eval(content.value)
        else
          push_string(content)
        end
      else
        push_string("<#{exp[:tag]}")
        render_attributes(exp)
        push_string(">")

        exp[:children].map(&method(:render_tree))

        push_string("</#{exp[:tag]}>")
      end
    end

    def render_attributes(exp)
      exp[:attributes].map do |pair|
        key = pair[:key]
        value = pair[:value]

        if value.is_a?(Eval)
          push_string(" #{key}=\"")
          push_eval(value.value)
          push_string("\"")
        else
          push_string(" #{key}=\"#{value}\"")
        end
      end
    end

    def component_tag?(exp)
      exp[:tag] && !!/[[:upper:]]/.match(exp[:tag][0])
    end

    def component_class(exp)
      Object.const_get(exp[:tag])
    end
  end
end
