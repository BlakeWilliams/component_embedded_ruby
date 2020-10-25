module ComponentEmbeddedRuby
  class Parser
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

      def parse_children
        RootParser.new(@token_reader).parse(inside_tag: true)
      end
    end
  end
end
