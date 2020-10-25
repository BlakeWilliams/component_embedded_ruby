module ComponentEmbeddedRuby
  module Parser
    class TagParser < Base
      def call
        # Expect opening carrot, e.g. < in <h1>
        expect(:open_carrot)

        # Expects an identifier, e.g. "h1"
        tag = expect(:identifier).value

        # Expects 0 or more attributes
        # e.g. id="hello" in <h1 id="hello">
        attributes = AttributeParser.new(@token_reader).call

        # Is this a self-closing element?
        if current_token.type == :slash
          expect(:slash)
          expect(:close_carrot)

          Node.new(tag, attributes, [])
        else
          expect(:close_carrot)

          children = parse_children

          expect(:open_carrot)
          expect(:slash)
          close_tag = expect(:identifier).value

          if close_tag != tag
            raise "Mismatched tags. expected #{tag}, got #{current_token.value}"
          end

          expect(:close_carrot)

          Node.new(tag, attributes, children)
        end
      end

      private

      # If the next two elements are </, we can safely asume it's meant to
      # close the current tag and lets us avoid having to attempt parsing
      # children.
      def has_children?
        return true if current_token.type != :open_carrot
        return true if peek_token&.type != :slash

        false
      end

      def parse_children
        if has_children?
          RootParser.new(@token_reader).call
        else
          []
        end
      end
    end
  end
end
