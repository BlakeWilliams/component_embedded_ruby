# frozen_string_literal: true

module ComponentEmbeddedRuby
  class UnexpectedTokenError < StandardError
    attr_reader :expected, :got

    def initialize(expected, got)
      @expected = expected
      @got = got
    end

    def message
      <<~MESSAGE.strip
        Unexpected token at line #{got.position.line}, column #{got.position.column}
        Got `#{got.value}`#{expected_message}
      MESSAGE
    end

    private

    def expected_message
      " but expected #{user_readable_expected}" unless expected.nil?
    end

    def user_readable_expected
      case expected
      when :open_carrot
        "`<`"
      when :close_carrot
        "`>`"
      when :equals
        "`=`"
      when :slash
        "`/`"
      else
        expected
      end
    end
  end
end
