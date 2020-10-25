# frozen_string_literal: true

module ComponentEmbeddedRuby
  class Eval
    attr_reader :value, :output

    def initialize(value, output: true)
      @value = value
      @output = output
    end

    def eval(binding)
      binding.instance_eval(value)
    end

    def ==(other)
      other.value == value
    end
  end
end
