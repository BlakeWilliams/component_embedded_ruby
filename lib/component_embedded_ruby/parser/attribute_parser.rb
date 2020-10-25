module ComponentEmbeddedRuby
  class Parser
    class AttributeParser < Base
      def call
        attributes = {}

        while current_token.type != :close_carrot && current_token.type != :slash
          attributes.merge!(parse_attribute)
        end

        attributes
      end

      private

      attr_reader :token_reader

      def parse_attribute
        key = expect(:identifier).value

        if current_token.type != :equals
          raise UnexpectedTokenError.new(:equals, current_token)
        else
          @token_reader.next
        end

        value_token = expect_any(:string, :ruby)

        if value_token.type == :string
          value = value_token.value
        else
          value = Eval.new(value_token.value)
        end

        { key => value }
      end

    end
  end
end
