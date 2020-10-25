require "test_helper"

module ComponentEmbeddedRuby
  class RendererTest < Minitest::Test
    class View
      def render(renderable, &block)
        renderable.render_in(&block)
      end

      def get_binding
        binding
      end
    end

    class Component < ViewComponent::Base
      def initialize(name:)
        @name = name
      end

      def render_in
        children = block_given? ? yield(self) : ""

        children + " #{name}"
      end

      private
      attr_reader :name
    end

    class SpanComponent < ViewComponent::Base
      def render_in
        children = block_given? ? yield(self) : ""

        "<span>" + children + "</span>"
      end
    end

    def test_handles_multiple_tags
      nodes = parse_and_lex("<h1>Hello!</h1><h6>Goodbye!</h6>")

      assert_equal "<h1>Hello!</h1><h6>Goodbye!</h6>", eval(Renderer.new(nodes).to_ruby)
    end

    def test_handles_nested_components_with_dynamic_binding
      view_model = Struct.new(:prefix, :suffix) do
        def render(renderable, &block)
          renderable.render_in(&block)
        end

        def get_binding
          binding
        end
      end

      nodes = parse_and_lex <<~EOF
      <ComponentEmbeddedRuby::RendererTest::Component name={suffix}>
        <ComponentEmbeddedRuby::RendererTest::Component name={prefix}>
          {- if 1 > 0 }
            hello
          {- end }
        </ComponentEmbeddedRuby::RendererTest::Component>
      </ComponentEmbeddedRuby::RendererTest::Component>
      EOF

      assert_equal "hello ruby rails", eval(Renderer.new(nodes).to_ruby, view_model.new("ruby", "rails").get_binding)
    end

    def parse_and_lex(content)
      Parser.parse(
        Lexer.new(content).lex
      )
    end
  end
end
