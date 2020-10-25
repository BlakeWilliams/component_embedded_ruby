require "component_embedded_ruby/parser/token_reader"

module ComponentEmbeddedRuby
  class Parser
    def initialize(tokens)
      @token_reader = TokenReader.new(tokens)
    end

    def parse(inside_tag: false)
      results = []

      while current_token
        case current_token.type
        when :open_carrot
          if next_token.type == :slash # close tag
            if inside_tag
              return results
            else
              nil
            end
          else
            results << parse_tag
          end
        when :string, :identifier
            results << Node.new(nil, nil, current_token.value).tap do
            @token_reader.next
          end
        when :ruby, :ruby_no_eval
          value = Eval.new(current_token.value, output: current_token.type == :ruby)

          results << Node.new(nil, nil, value).tap do
            @token_reader.next
          end
        else
          if inside_tag
            return results
          end
        end
      end

      results
    end

    private

    def parse_tag
      @token_reader.next

      tag = expect(:identifier).value
      attributes = parse_attributes

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

    def parse_children
      parse(inside_tag: true)
    end

    def parse_attributes
      attributes = {}

      while current_token.type != :close_carrot && current_token.type != :slash
        attributes.merge!(parse_attribute)
      end

      attributes
    end

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

    def current_token
      @token_reader.current_token
    end

    def next_token
      @token_reader.peek
    end

    def expect(type)
      token = current_token

      if token.type != type
        raise UnexpectedTokenError.new(:string, current_token)
      else
        @token_reader.next
      end

      token
    end

    def expect_any(*types)
      token = current_token

      if !types.include?(token.type)
        raise UnexpectedTokenError.new(:string, token)
      else
        @token_reader.next
      end

      token
    end
  end
end
