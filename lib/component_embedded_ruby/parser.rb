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
        @position += 1
        {
          tag: nil,
          attributes: nil,
          children: current_token.value
        }
      else
        raise "Unexpected token" # TODO line numbers, custom exception
      end
    end

    def parse_open_tag
      @position +=1 # already matching a <

      if current_token.type != :identifier
        raise "Unexpected token, expected string"
      else
        tag = current_token.value
      end

      @position += 1
      parse_attributes

      children = []
      child = parse_tag

      while child != nil
        children.push(child)
        child = parse_tag
      end

      if current_token.type != :open_carrot
        raise "Unexpected token, expected <"
      else
        @position += 1
      end

      if current_token.type != :slash
        raise "Unexpected token, expected /"
      else
        @position += 1
      end

      if current_token.type != :identifier
        raise "Unexpected token, expected closing string"
      elsif current_token.value != tag
        raise "Mismatched tags. expected #{tag}, got #{current_token.value}"
      else
        @position += 1
      end

      if current_token.type != :close_carrot
        raise "Unexpected token, expected >"
      else
        @position += 1
      end

      {
        tag: tag,
        attributes: [],
        children: children,
      }
    end

    def parse_attributes
      attributes = []

      while current_token.type != :close_carrot
        attributes.push(parse_attribute)
      end

      @position += 1

      attributes
    end

    def parse_attribute
      if current_token.type != :identifier
        raise "unexpected token, expected string"
      else
        key = current_token.value
        @position += 1
      end

      if current_token.type != :equals
        raise "unexpected token, expected equals"
      else
        @position += 1
      end

      if current_token.type != :string
        raise "unexpected token, expected string"
      else
        value = current_token.value
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
