module ComponentEmbeddedRuby
  class Node
    attr_reader :tag, :attributes, :children

    def initialize(tag, attributes, children)
      @tag = tag
      @attributes = attributes
      @children = children
    end

    def ==(other)
      if other
        other.tag == tag && other.attributes == attributes && other.children == children
      else
        false
      end
    end

    def component_class
      @_component_class = Object.const_get(tag)
    end

    # If the tag starts with a capital, we assume it's a component
    def component?
      @_component ||= tag && !!/[[:upper:]]/.match(tag[0])
    end
  end
end
