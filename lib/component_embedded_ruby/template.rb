# frozen_string_literal: true

module ComponentEmbeddedRuby
  class Template
    def initialize(
      template,
      safe_append_method: "<<",
      unsafe_append_method: "<<",
      output_var_name: "__crb_out"
    )
      @template = template
      @safe_append_method = safe_append_method
      @unsafe_append_method = unsafe_append_method
      @output_var_name = output_var_name
    end

    def to_ruby
      tokens = Lexer.new(@template).lex
      nodes = Parser.parse(tokens)
      Compiler.new(
        nodes,
        safe_append_method: @safe_append_method,
        unsafe_append_method: @unsafe_append_method,
        output_var_name: @output_var_name
      ).to_ruby
    end

    def to_s(binding: TOPLEVEL_BINDING)
      eval(to_ruby, binding) # rubocop:disable Security/Eval
    end
  end
end
