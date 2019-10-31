module ComponentEmbeddedRuby
  class UnexpectedTokenError < StandardError
    attr_reader :expected, :got

    def initialize(expected, got)
      @expected = expected
      @got = got
    end

    def message
      "Unexpected token at column #{got.position}, got #{got.value}#{expected_message}."
    end

    private

    def expected_message
      if expected != nil
        " but expected #{expected}"
      end
    end
  end
end
