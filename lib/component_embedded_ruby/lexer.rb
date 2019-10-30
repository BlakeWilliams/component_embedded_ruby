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

    def lex
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
          # TODO parse between quotes
          tokens.push(
            Token.new(TOKEN_STRING, read_quoted_string)
          )
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

    def read_quoted_string
      string = ""

      # Get past initial "
      @position += 1

      while !unescaped_quote?
        raise "unterminated string" if @position > @content.length
        string += @content[@position]
        @position += 1
      end

      # Get past last "
      @position += 1

      string
    end

    def unescaped_quote?
      @content[@position] == "\"" && @content[@position -1] != "\\"
    end

    def is_letter?(char)
      ascii = char.ord
      (ascii >= 48 && ascii <= 57) || (ascii >= 65 && ascii <= 122) || ascii == 45 || ascii == 95
    end
  end
end
