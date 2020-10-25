module ComponentEmbeddedRuby
  module Parser
    # Internal: Parses an HTML tag attributes into a hash of key values
    #
    # This class parses HTML attributes into a hash of key values, keys are
    # always strings but since values can be dynamic, they will either be a
    # string or an instance of `Eval`.
    #
    # Given how we parse these attributes, they are intentionally either a
    # string or Ruby, not a combination of the two.
    #
    # Valid attributes may look like `id="document" class={my_classes}`
    #
    # The following is invalid `class="mb-0 {my_classes}"`
    #
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
        expect(:equals)
        value = parse_value

        { key => value }
      end

      def parse_value
        value_token = expect_any(:string, :ruby)

        if value_token.type == :string
          value_token.value
        else
          Eval.new(value_token.value)
        end
      end
    end
  end
end
