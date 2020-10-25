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

        if token.type != type
          raise UnexpectedTokenError.new(type, current_token)
        else
          token_reader.next
        end

        token
      end

      def expect_any(*types, expected_message:)
        token = current_token

        if !types.include?(token.type)
          raise UnexpectedTokenError.new(expected_message, token)
        else
          token_reader.next
        end

        token
      end
    end
  end
end
