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

    def render_tree(node)
      if node.component?
        render_component(node)
      else
        render_tag(node)
      end
    end

    def render_component(node)
      @func << " + #{node.component_class}.new().render({"

      @func << (node.attributes.map do |attr|
        key = " :\"#{attr[:key]}\" => "

        value = if attr[:value].is_a?(Eval)
          "#{attr[:value].value}"
        else
          "\"#{attr[:value]}\""
        end

        key + value
      end.join(', '))

      @func << "}, ''"

      node.children.map(&method(:render_tag)).join("")

      @func << ')'
    end

    def render_tag(node)
      if node.tag.nil?
        content = node.children

        if content.is_a?(Eval)
          push_eval(content.value)
        else
          push_string(content)
        end
      else
        push_string("<#{node.tag}")
        render_attributes(node)
        push_string(">")

        node.children.map(&method(:render_tree))

        push_string("</#{node.tag}>")
      end
    end

    def render_attributes(node)
      node.attributes.map do |pair|
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
  end
end
