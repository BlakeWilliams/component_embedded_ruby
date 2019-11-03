module ComponentEmbeddedRuby
  class Renderer
    def initialize(nodes, output_var_name: "__crb_out")
      @nodes = Array(nodes)
      @functions = {}
      @output_var_name = output_var_name
    end

    def to_s(binding: TOPLEVEL_BINDING)
      eval(to_ruby, binding)
    end

    def to_ruby
      text = <<~EOF
        #{output_var_name} = '';

        #{nodes.map(&method(:render)).join("\n")}

        #{output_var_name}\n
      EOF
    end

    def render(node)
      if node.component?
        child_output = self.class.new(node.children, output_var_name: "__c_#{node.hash.to_s.gsub("-", "_")}").to_ruby
        "#{child_output}\n #{output_var_name}.<< #{node.component_class}.new.render({ #{attributes_for_component(node).join(",")} }, __c_#{node.hash.to_s.gsub("-", "_")});\n"
      elsif node.ruby?
        if node.output_ruby?
          "#{output_var_name}.<< (#{node.children.value}).to_s;\n"
        else
          "#{node.children.value};\n"
        end
      elsif node.text?
        "#{output_var_name}.<< \"#{node.children}\";\n"
      elsif node.html?
        "#{output_var_name}.<< \"<#{node.tag}\";\n" +
          attributes_for_tag(node).join("\n") +
          "#{output_var_name}.<< \">\";\n" +
          node.children.map(&method(:render)).join("\n") +
          "#{output_var_name}.<< \"</#{node.tag}>\""
      end
    end

    private

    attr_reader :output_var_name

    def attributes_for_component(node)
      node.attributes.map do |key, value|
        if value.is_a?(Eval)
          " :\"#{key}\" => #{value.value}"
        else
          " :\"#{key}\" => \"#{value}\""
        end
      end
    end

    def attributes_for_tag(node)
      node.attributes.map do |key, value|
        if value.is_a?(Eval)
          <<~EOF
          #{output_var_name}.<< " #{key}=\\"";
          #{output_var_name}.<< (#{value.value}).to_s;
          #{output_var_name}.<< "\\"";
          EOF
        else
          %W(#{output_var_name}.<< "key="";\n)
        end
      end
    end

    attr_reader :nodes
  end
end
