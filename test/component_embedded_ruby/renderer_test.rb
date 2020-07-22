require "test_helper"

module ComponentEmbeddedRuby
  class RendererTest < Minitest::Test
    class View
      def render(renderable, &block)
        renderable.render_in &block
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

      assert_equal "<h1>Hello!</h1><h6>Goodbye!</h6>", Renderer.new(nodes).to_s
    end

    def test_handles_top_level_ruby
      nodes = parse_and_lex <<~EOF
      {- if 1 == 0 }
        never hit
      {- else }
        true
      {- end }
      EOF

      assert_equal "true", Renderer.new(nodes).to_s
    end

    def test_handles_components
      nodes = parse_and_lex <<~EOF
      <ComponentEmbeddedRuby::RendererTest::Component name="ruby">
        {- if 1 > 0 }
          hello
        {- end }
      </ComponentEmbeddedRuby::RendererTest::Component>
      EOF

      assert_equal "hello ruby", Renderer.new(nodes).to_s(binding: View.new.get_binding)
    end

    def test_handles_nested_components
      nodes = parse_and_lex <<~EOF
      <ComponentEmbeddedRuby::RendererTest::Component name="rails">
        <ComponentEmbeddedRuby::RendererTest::Component name="ruby">
          {- if 1 > 0 }
            hello
          {- end }
        </ComponentEmbeddedRuby::RendererTest::Component>
      </ComponentEmbeddedRuby::RendererTest::Component>
      EOF

      assert_equal "hello ruby rails", Renderer.new(nodes).to_s(binding: View.new.get_binding)
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

      assert_equal "hello ruby rails", Renderer.new(nodes).to_s(binding: view_model.new("ruby", "rails").get_binding)
    end

    def test_handles_looped_nested_components
      view_model = Struct.new(:names) do
        def render(renderable, &block)
          renderable.render_in(&block)
        end

        def get_binding
          binding
        end
      end

      nodes = parse_and_lex <<~EOF
      {- names.each do |name|}
        <ComponentEmbeddedRuby::RendererTest::SpanComponent>
          <ComponentEmbeddedRuby::RendererTest::Component name={name}>
          {- if name == "mulder" }
            hello
          {- else }
            hey
          {- end }
          </ComponentEmbeddedRuby::RendererTest::Component>
        </ComponentEmbeddedRuby::RendererTest::SpanComponent>
      {- end }
      EOF

      assert_equal "<span>hello mulder</span><span>hey scully</span>", Renderer.new(nodes).to_s(binding: view_model.new(["mulder", "scully"]).get_binding)
    end

    def parse_and_lex(content)
      Parser.new(
        Lexer.new(content).lex
      ).parse
    end
  end
end
