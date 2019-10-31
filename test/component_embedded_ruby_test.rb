require "test_helper"

class ComponentEmbeddedRubyTest < Minitest::Test
  class View
    def id
      "identifier"
    end

    def content
      "Hello world!"
    end
  end

  class Component
    def initialize(attrs)
      @attrs = attrs
    end

    def render(children)
      "<div>" +
        "#{children.upcase}" +
      "</div>"
    end
  end

  def test_that_it_has_a_version_number
    refute_nil ::ComponentEmbeddedRuby::VERSION
  end

  def test_it_converts_to_html
    binding_class = View.new

    template = ComponentEmbeddedRuby.template(
      "<h1 id={id}>{content}</h1>",
      binding_class
    )

    assert_equal '<h1 id="identifier">Hello world!</h1>', template.to_s
  end

  def test_it_renders_components
    binding_class = View.new

    template = ComponentEmbeddedRuby.template(
      '<h1 id={id}><ComponentEmbeddedRubyTest::Component capitalize="true">hello world</ComponentEmbeddedRubyTest::Component></h1>',
      binding_class
    )

    assert_equal '<h1 id="identifier"><div>HELLO WORLD</div></h1>', template.to_s
  end
end
