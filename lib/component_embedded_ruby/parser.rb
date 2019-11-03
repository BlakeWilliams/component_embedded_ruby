module ComponentEmbeddedRuby
  class Parser
    def initialize(tokens)
      @tokens = tokens
      @position = 0
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
            @position += 1
          end
        when :ruby, :ruby_no_eval
          value = Eval.new(current_token.value, output: current_token.type == :ruby)

          results << Node.new(nil, nil, value).tap do
            @position += 1
          end
        else
          if inside_tag
            return results
            raise UnexpectedTokenError.new(nil, current_token)
          end
        end
      end

      results
    end

    private

    attr_reader :tokens

    def parse_tag
      @position +=1 # already matching a <

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
      children = parse(inside_tag: true)
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
        @position += 1
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
      tokens[@position]
    end

    def next_token
      tokens[@position + 1]
    end

    def expect(type)
      token = current_token

      if token.type != type
        raise UnexpectedTokenError.new(:string, current_token)
      else
        @position += 1
      end

      token
    end

    def expect_any(*types)
      token = current_token

      if !types.include?(token.type)
        raise UnexpectedTokenError.new(:string, token)
      else
        @position += 1
      end

      token
    end
  end
end
