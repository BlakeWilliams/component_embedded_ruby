module ComponentEmbeddedRuby
  class Lexer
    Token = Struct.new(:type, :value)

    def initialize(content)
      @content = content.freeze
      @position = 0
    end

    def lex
      tokens = []

      while position != @content.length
        char = content[@position]

        if char == "<"
          tokens.push(Token.new(:open_carrot, nil))
          @position += 1
        elsif char == ">"
          tokens.push(Token.new(:close_carrot, nil))
          @position += 1
        elsif char == "="
          tokens.push(Token.new(:equals, nil))
          @position += 1
        elsif char == "\""
          tokens.push(
            Token.new(:string, read_quoted_string)
          )
        elsif char == "/"
          tokens.push(Token.new(:slash, nil))
          @position += 1
        elsif is_letter?(char)
          tokens.push(
            Token.new(:string, read_string)
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
