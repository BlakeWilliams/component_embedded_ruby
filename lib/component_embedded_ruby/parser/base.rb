# frozen_string_literal: true

module ComponentEmbeddedRuby
  module Parser
    class Base
      def initialize(token_reader)
        @token_reader = token_reader
      end

      private

      attr_reader :token_reader

      def current_token
        token_reader.current_token
      end

      def peek_token
        token_reader.peek_token
      end

      def expect(type)
        token = current_token
        raise UnexpectedTokenError.new(type, current_token) if token.type != type

        token_reader.next
        token
      end

      def expect_any(*types, expected_message:)
        token = current_token
        raise UnexpectedTokenError.new(expected_message, token) unless types.include?(token.type)

        token_reader.next
        token
      end
    end
  end
end
