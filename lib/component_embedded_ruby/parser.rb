module ComponentEmbeddedRuby
  class Parser
    def initialize(tokens)
      @tokens = tokens
      @position = 0
    end

    def parse
      parse_tag
    end

    private

    attr_reader :tokens

    def parse_tag
      if current_token.type == :open_carrot && next_token.type == :slash
        nil
      elsif current_token.type == :open_carrot && next_token.type != :slash
        parse_open_tag
      elsif current_token.type == :string
        tag = {
          tag: nil,
          attributes: nil,
          children: current_token.value
        }.tap do
          @position += 1
        end
      elsif current_token.type == :ruby
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

    def parse_open_tag
      @position +=1 # already matching a <

      if current_token.type != :identifier
        raise UnexpectedTokenError.new(:identifier, current_token)
      else
        tag = current_token.value
      end

      @position += 1
      attributes = parse_attributes

      if current_token.type == :slash
        @position += 1

        if current_token.type != :close_carrot
          raise UnexpectedTokenError.new(:close_carrot, current_token)
        else
          @position += 1
        end

        {
          tag: tag,
          attributes: attributes,
          children: [],
        }
      else
        @position += 1

        children = parse_children

        if current_token.type != :open_carrot
          raise UnexpectedTokenError.new(:open_carrot, current_token)
        else
          @position += 1
        end

        if current_token.type != :slash
          raise UnexpectedTokenError.new(:slash, current_token)
        else
          @position += 1
        end

        if current_token.type != :identifier
          raise UnexpectedTokenError.new(:identifier, current_token)
        elsif current_token.value != tag
          raise "Mismatched tags. expected #{tag}, got #{current_token.value}"
        else
          @position += 1
        end

        if current_token.type != :close_carrot
          raise UnexpectedTokenError.new(:close_carrot, current_token)
        else
          @position += 1
        end

        {
          tag: tag,
          attributes: attributes,
          children: children,
        }
      end
    end

    def parse_children
      children = []
      child = parse_tag

      while child != nil
        children.push(child)
        child = parse_tag
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
      if current_token.type != :identifier
        raise UnexpectedTokenError.new(:identifier, current_token)
      else
        key = current_token.value
        @position += 1
      end

      if current_token.type != :equals
        raise UnexpectedTokenError.new(:equals, current_token)
      else
        @position += 1
      end

      if current_token.type != :string && current_token.type != :ruby
        raise UnexpectedTokenError.new(:string, current_token)
      else
        if current_token.type == :string
          value = current_token.value
        else
          value = Eval.new(current_token.value)
        end
        @position += 1
      end

      { key: key, value: value }
    end

    def current_token
      tokens[@position]
    end

    def next_token
      tokens[@position + 1]
    end
  end
end
