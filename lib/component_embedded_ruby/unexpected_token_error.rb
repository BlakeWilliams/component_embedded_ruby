module ComponentEmbeddedRuby
  class UnexpectedTokenError < StandardError
    attr_reader :expected, :got

    def initialize(expected, got)
      @expected = expected
      @got = got
    end

    def message
      "Unexpected token at line #{got.position.line}, column #{got.position.column}\nGot `#{got.value}`#{expected_message}"
    end

    private

    def expected_message
      if expected != nil
        " but expected `#{user_readable_expected}`"
      end
    end

    def user_readable_expected
      case expected
      when :open_carrot
        "<"
      when :close_carrot
        ">"
      when :equals
        "="
      when :slash
        "/"
      else
        expected
      end
    end
  end
end
