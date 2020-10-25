module ComponentEmbeddedRuby
  class Parser
    class TokenReader
      def initialize(tokens)
        @tokens = tokens
        @position = 0
      end

      def current_token
        @tokens[@position]
      end

      def peek_token(n = 1)
        @tokens[@position + n]
      end

      def next
        @position += 1
      end
    end
  end
end
