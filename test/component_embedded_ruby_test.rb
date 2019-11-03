require "test_helper"

class ComponentEmbeddedRubyTest < Minitest::Test
  class View
    def id
      "identifier"
    end

    def content
      "Hello world!"
    end

    def get_binding
      binding
    end
  end

  class Component
    def render(attrs, children)
      "<div data-capitalize=\"#{attrs[:capitalize]}\">" +
        "#{children.upcase}" +
      "</div>"
    end
  end

  def test_that_it_has_a_version_number
    refute_nil ::ComponentEmbeddedRuby::VERSION
  end

  def test_it_converts_to_html
    result = ComponentEmbeddedRuby.render(
      "<h1 id={id}>{content}</h1>",
      binding: View.new.get_binding
    )

    assert_equal '<h1 id="identifier">Hello world!</h1>', result
  end

  def test_it_renders_components
    binding_class = View.new

    result = ComponentEmbeddedRuby.render(
      %(
        <h1 id={id}>
          <ComponentEmbeddedRubyTest::Component capitalize="true" id={id}>
            {content}
          </ComponentEmbeddedRubyTest::Component>
        </h1>
      ),
      binding: binding_class.get_binding
    )

    expected = "<h1 id=\"identifier\"><div data-capitalize=\"true\">HELLO WORLD!</div></h1>"

    assert_equal expected, result
  end


  def test_handles_if_statements
    binding_class = View.new

    result = ComponentEmbeddedRuby.render(
      %(
        <h1 id={id}>
          {- if 1 > 0}
            hello
          {- else }
            wat
          {- end }
        </h1>
      ),
      binding: binding_class.get_binding
    )

    expected = "<h1 id=\"identifier\">hello</h1>"

    assert_equal expected, result
  end

  def test_handles_top_level_escaped_ruby
    binding_class = View.new

    result = ComponentEmbeddedRuby.render(
      %(
        {- if false }
          hello
        {- else }
          wat
        {- end }
      ),
      binding: binding_class.get_binding
    )

    expected = "wat"

    assert_equal expected, result
  end

  def test_handles_if_statements_in_components
    binding_class = View.new

    result = ComponentEmbeddedRuby.render(
      %(
        <h1 id={id}>
          <ComponentEmbeddedRubyTest::Component capitalize="true" id={id}>
            {- if 1 > 0}
              {content}
            {- else }
              wat
            {- end }
          </ComponentEmbeddedRubyTest::Component>
        </h1>
      ),
      binding: binding_class.get_binding
    )

    expected = "<h1 id=\"identifier\"><div data-capitalize=\"true\">HELLO WORLD!</div></h1>"

    assert_equal expected, result
  end
end
