# frozen_string_literal: true

require "test_helper"

module ComponentEmbeddedRuby
  class NodeTest < Minitest::Test
    class RealComponent
    end

    def test_component_returns_true_if_starts_with_capital_letter
      node = Node.new("RealComponent", nil, nil)

      assert node.component?
    end

    def test_component_returns_false_if_does_not_start_with_capital_letter
      node = Node.new("justhtml", nil, nil)

      refute node.component?
    end

    def test_component_class_returns_the_constant
      node = Node.new("ComponentEmbeddedRuby::NodeTest::RealComponent", nil, nil)

      assert_equal RealComponent, node.component_class
    end
  end
end
