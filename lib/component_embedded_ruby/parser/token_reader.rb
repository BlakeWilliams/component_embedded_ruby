module ComponentEmbeddedRuby
  module Parser
    class TokenReader
      def initialize(tokens)
        @tokens = tokens
        @position = 0
      end

      def current_token
        @tokens[@position]
      end

      def peek_token
        @tokens[@position + 1]
      end

      def next
        @position += 1
      end
    end
  end
end
