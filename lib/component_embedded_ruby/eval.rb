module ComponentEmbeddedRuby
  class Eval
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def eval(binding)
      binding.instance_eval(value)
    end

    def ==(other)
      other.value == value
    end
  end
end
