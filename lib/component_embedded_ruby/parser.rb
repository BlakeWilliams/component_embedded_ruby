module ComponentEmbeddedRuby
  class Parser
    def initialize(tokens)
      @tokens = tokens
      @position = 0
    end

    def parse
      case current_token.type
      when :open_carrot
        if peek_token.type == :slash # close tag
          nil
        else
          parse_tag # open tag
        end
      when :string
        tag = {
          tag: nil,
          attributes: nil,
          children: current_token.value
        }.tap do
          @position += 1
        end
      when :ruby
        tag = {
          tag: nil,
          attributes: nil,
          children: Eval.new(current_token.value)
        }.tap do
          @position += 1
        end
      else
        raise UnexpectedTokenError.new(nil, current_token)
      end
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

        {
          tag: tag,
          attributes: attributes,
          children: [],
        }
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

        {
          tag: tag,
          attributes: attributes,
          children: children,
        }
      end
    end

    def parse_children
      children = []
      child = parse

      while child != nil
        children.push(child)
        child = parse
      end

      children
    end

    def parse_attributes
      attributes = []

      while current_token.type != :close_carrot && current_token.type != :slash
        attributes.push(parse_attribute)
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

      { key: key, value: value }
    end

    def current_token
      tokens[@position]
    end

    def peek_token
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
