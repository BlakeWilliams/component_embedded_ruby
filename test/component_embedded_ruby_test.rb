# frozen_string_literal: true

require "test_helper"

class ComponentEmbeddedRubyTest < Minitest::Test
  class View
    def id
      "identifier"
    end

    def content
      "Hello world!"
    end

    def render(renderable, &block)
      renderable.render_in(&block)
    end

    def get_binding
      binding
    end
  end

  class Component
    def initialize(capitalize:, id: nil)
      @capitalize = capitalize
      @id = id
    end

    # override render_in because crb doesn't care about view context yet
    def render_in
      content = block_given? ? yield(self) : ""

      "<div data-capitalize=\"#{@capitalize}\">#{content&.upcase}</div>"
    end
  end

  class ChildRenderComponent
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

      "<span>#{children}</span>"
    end
  end

  def test_that_it_has_a_version_number
    refute_nil ::ComponentEmbeddedRuby::VERSION
  end

  def test_it_converts_to_html
    result = render(
      "<h1 id={id}>{content}</h1>",
      binding: View.new.get_binding
    )

    assert_equal '<h1 id="identifier">Hello world!</h1>', result
  end

  def test_it_converts_static_attributes
    result = render(
      "<h1 id=\"1\">{content}</h1>",
      binding: View.new.get_binding
    )

    assert_equal '<h1 id="1">Hello world!</h1>', result
  end

  def test_it_renders_components
    binding_class = View.new

    result = render(
      %(
        <h1 id={id}>
          <ComponentEmbeddedRubyTest::Component capitalize="true" id={id}>
            {content}
          </ComponentEmbeddedRubyTest::Component>
        </h1>
      ),
      binding: binding_class.get_binding
    )

    expected = '<h1 id="identifier"><div data-capitalize="true">HELLO WORLD!</div></h1>'

    assert_equal expected, result
  end

  def test_it_renders_nested_components
    result = render(
      %(
        <h1 id={id}>
          <ComponentEmbeddedRubyTest::SpanComponent>
            <ComponentEmbeddedRubyTest::Component capitalize="true" id={id}>
              {content}
            </ComponentEmbeddedRubyTest::Component>
          </ComponentEmbeddedRubyTest::SpanComponent>
        </h1>
      ),
      binding: View.new.get_binding
    )

    expected = '<h1 id="identifier"><span><div data-capitalize="true">HELLO WORLD!</div></span></h1>'

    assert_equal expected, result
  end

  def test_handles_if_statements
    result = render(
      %(
        <h1 id={id}>
          {- if 1 > 0}
            hello
          {- else }
            wat
          {- end }
        </h1>
      ),
      binding: View.new.get_binding
    )

    expected = '<h1 id="identifier">hello</h1>'

    assert_equal expected, result
  end

  def test_handles_top_level_escaped_ruby
    binding_class = View.new

    result = render(<<~ERB, binding: binding_class.get_binding)
      {- if false }
        hello
      {- else }
        wat
      {- end }
    ERB

    expected = "wat"

    assert_equal expected, result
  end

  def test_handles_if_statements_in_components
    binding_class = View.new

    result = render(<<~RUBY, binding: binding_class.get_binding)
      <h1 id={id}>
        <ComponentEmbeddedRubyTest::Component capitalize="true" id={id}>
          {- if 1 > 0}
            {content}
          {- else }
            wat
          {- end }
        </ComponentEmbeddedRubyTest::Component>
      </h1>
    RUBY

    expected = '<h1 id="identifier"><div data-capitalize="true">HELLO WORLD!</div></h1>'

    assert_equal expected, result
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

    result = render(<<~RUBY, binding: view_model.new(%w[mulder scully]).get_binding)
      {- names.each do |name|}
        <ComponentEmbeddedRubyTest::SpanComponent>
          <ComponentEmbeddedRubyTest::ChildRenderComponent name={name}>
            {- if name == "mulder" }
              hello
            {- else }
              hey
            {- end }
          </ComponentEmbeddedRubyTest::ChildRenderComponent>
        </ComponentEmbeddedRubyTest::SpanComponent>
      {- end }
    RUBY

    assert_equal "<span>hello mulder</span><span>hey scully</span>", result
  end

  def render(source, binding: TOPLEVEL_BINDING)
    ComponentEmbeddedRuby::Template.new(source).to_s(binding: binding)
  end
end
