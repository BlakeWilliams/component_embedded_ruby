module ComponentEmbeddedRuby
  class Parser
    class TagParser
      def initialize(parser)
        @parser = parser
      end

      def to_node
      end

      def parse
        parser.move

        if parser.current_token.type != :identifier
          raise UnexpectedTokenError.new(:identifier, parser.current_token)
        else
          tag = parser.current_token.value
        end

        parser.move
        attributes = parse_attributes

        if parser.current_token.type == :slash
          parser.move

          if parser.current_token.type != :close_carrot
            raise UnexpectedTokenError.new(:close_carrot, parser.current_token)
          else
            parser.move
          end

          {
            tag: tag,
            attributes: attributes,
            children: [],
          }
        else
          parser.move

          children = parse_children

          if parser.current_token.type != :open_carrot
            raise UnexpectedTokenError.new(:open_carrot, parser.current_token)
          else
            parser.move
          end

          if parser.current_token.type != :slash
            raise UnexpectedTokenError.new(:slash, parser.current_token)
          else
            parser.move
          end

          if parser.current_token.type != :identifier
            raise UnexpectedTokenError.new(:identifier, parser.current_token)
          elsif parser.current_token.value != tag
            raise "Mismatched tags. expected #{tag}, got #{parser.current_token.value}"
          else
            parser.move
          end

          if parser.current_token.type != :close_carrot
            raise UnexpectedTokenError.new(:close_carrot, parser.current_token)
          else
            parser.move
          end

          {
            tag: tag,
            attributes: attributes,
            children: children,
          }
        end
      end

      private

      def parse_children
        children = []
        child = parser.parse_tag

        while child != nil
          children.push(child)
          child = parser.parse_tag
        end

        children
      end

      def parse_attributes
        attributes = []

        while parser.current_token.type != :close_carrot && parser.current_token.type != :slash
          attributes.push(parse_attribute)
        end

        attributes
      end

      def parse_attribute
        if parser.current_token.type != :identifier
          raise UnexpectedTokenError.new(:identifier, parser.current_token)
        else
          key = parser.current_token.value
          parser.move
        end

        if parser.current_token.type != :equals
          raise UnexpectedTokenError.new(:equals, parser.current_token)
        else
          parser.move
        end

        if parser.current_token.type != :string && parser.current_token.type != :ruby
          raise UnexpectedTokenError.new(:string, parser.current_token)
        else
          if parser.current_token.type == :string
            value = parser.current_token.value
          else
            value = Eval.new(parser.current_token.value)
          end
          parser.move
        end

        { key: key, value: value }
      end

      attr_reader :parser
    end
  end
end
