# frozen_string_literal: true

module ComponentEmbeddedRuby
  class Compiler
    def initialize(nodes, output_var_name: "__crb_out", skip_return: false)
      @nodes = Array(nodes)
      @functions = {}
      @output_var_name = output_var_name
      @skip_return = skip_return
    end

    def to_ruby
      <<~RUBY
        #{output_var_name} = '';

        #{nodes.map(&method(:render)).join("\n")}

        #{output_var_name unless @skip_return};
      RUBY
    end

    private

    def render(node) # rubocop:disable Metrics/PerceivedComplexity
      if node.component?
        <<~RUBY
          #{children_to_ruby(node)}
          #{output_var_name}.<< render(#{node.component_class}.new(#{attributes_for_component(node).join(',')})) { |component|
             __c_#{node.hash.to_s.gsub('-', '_')}
          };
        RUBY
      elsif node.ruby?
        if node.output_ruby?
          "#{output_var_name}.<< (#{node.children.value}).to_s;\n"
        else
          "#{node.children.value};\n"
        end
      elsif node.text?
        "#{output_var_name}.<< \"#{node.children}\";\n"
      elsif node.html?
        <<~RUBY
          #{output_var_name}.<< \"<#{node.tag}\";
          #{attributes_for_tag(node).join("\n")};
          #{output_var_name}.<< \">\";
          #{node.children.map(&method(:render)).join("\n")}
          #{output_var_name}.<< \"</#{node.tag}>\";
        RUBY
      end
    end

    attr_reader :output_var_name, :nodes

    def children_to_ruby(node)
      self.class.new(
        node.children,
        output_var_name: "__c_#{node.hash.to_s.gsub('-', '_')}",
        skip_return: true
      ).to_ruby
    end

    def attributes_for_component(node)
      node.attributes.map do |key, value|
        if value.is_a?(Eval)
          " #{key}: #{value.value}"
        else
          " #{key}: \"#{value}\""
        end
      end
    end

    def attributes_for_tag(node)
      node.attributes.map do |key, value|
        if value.is_a?(Eval)
          <<~RUBY
            #{output_var_name}.<< " #{key}=\\"";
            #{output_var_name}.<< (#{value.value}).to_s;
            #{output_var_name}.<< "\\"";
          RUBY
        else
          %W[#{output_var_name}.<< "key="";\n]
        end
      end
    end
  end
end
