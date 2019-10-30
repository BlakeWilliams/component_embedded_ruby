module ComponentEmbeddedRuby
  class Lexer
    TOKEN_OPEN_CARROT = "<"
    TOKEN_CLOSE_CARROT = ">"
    TOKEN_EQUALS = "="
    TOKEN_QUOTE = "\""
    TOKEN_SLASH = "/"
    TOKEN_STRING = "token_string"
    Token = Struct.new(:type, :value)

    def initialize(content)
      @content = content.freeze
      @position = 0
    end

    def parse
      tokens = []

      while position != @content.length
        char = content[@position]

        if char == TOKEN_OPEN_CARROT
          tokens.push(Token.new(TOKEN_OPEN_CARROT, nil))
          @position += 1
        elsif char == TOKEN_CLOSE_CARROT
          tokens.push(Token.new(TOKEN_CLOSE_CARROT, nil))
          @position += 1
        elsif char == TOKEN_EQUALS
          tokens.push(Token.new(TOKEN_EQUALS, nil))
          @position += 1
        elsif char == TOKEN_QUOTE
          tokens.push(Token.new(TOKEN_QUOTE, nil))
          @position += 1
        elsif char == TOKEN_SLASH
          tokens.push(Token.new(TOKEN_SLASH, nil))
          @position += 1
        elsif is_letter?(char)
          tokens.push(
            Token.new(TOKEN_STRING, read_string)
          )
        else
          @position += 1
        end
      end

      tokens
    end

    private

    attr_reader :content
    attr_accessor :position

    def read_string
      string = ""

      while is_letter?(@content[@position]) && @position < @content.length
        string += @content[@position]
        @position += 1
      end

      string
    end

    def is_letter?(char)
      ascii = char.ord
      (ascii >= 48 && ascii <= 57) || (ascii >= 65 && ascii <= 122)
    end
  end
end
