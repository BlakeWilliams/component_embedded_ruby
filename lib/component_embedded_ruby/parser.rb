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
      if current_token.type == Lexer::TOKEN_OPEN_CARROT && next_token.type == Lexer::TOKEN_SLASH
        nil
      elsif current_token.type == Lexer::TOKEN_OPEN_CARROT && next_token.type != Lexer::TOKEN_SLASH
        parse_open_tag
      elsif current_token.type == Lexer::TOKEN_STRING
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

      if current_token.type != Lexer::TOKEN_STRING
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

      if current_token.type != Lexer::TOKEN_OPEN_CARROT
        raise "Unexpected token, expected <"
      else
        @position += 1
      end

      if current_token.type != Lexer::TOKEN_SLASH
        raise "Unexpected token, expected /"
      else
        @position += 1
      end

      if current_token.type != Lexer::TOKEN_STRING
        raise "Unexpected token, expected closing string"
      elsif current_token.value != tag
        raise "Mismatched tags. expected #{tag}, got #{current_token.value}"
      else
        @position += 1
      end

      if current_token.type != Lexer::TOKEN_CLOSE_CARROT
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

      while current_token.type != Lexer::TOKEN_CLOSE_CARROT
        attributes.push(parse_attribute)
      end

      @position += 1

      attributes
    end

    def parse_attribute
      if current_token.type != Lexer::TOKEN_STRING
        raise "unexpected token, expected string"
      else
        key = current_token.value
        @position += 1
      end

      if current_token.type != Lexer::TOKEN_EQUALS
        raise "unexpected token, expected equals"
      else
        @position += 1
      end

      # TODO remove and turn into quoted string type
      if current_token.type != Lexer::TOKEN_QUOTE
        raise "unexpected token, expected start quote"
      else
        @position += 1
      end

      if current_token.type != Lexer::TOKEN_STRING
        raise "unexpected token, expected string"
      else
        value = current_token.value
        @position += 1
      end

      # TODO remove and turn into quoted string type
      if current_token.type != Lexer::TOKEN_QUOTE
        raise "unexpected token, expected end quote"
      else
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
