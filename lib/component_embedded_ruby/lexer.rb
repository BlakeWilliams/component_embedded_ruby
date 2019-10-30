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
        elsif char == "{"
          tokens.push(Token.new(:ruby, read_ruby_string))
        elsif tokens.last.type == :close_carrot && is_letter?(char)
          tokens.push(
            Token.new(:string, read_body_string)
          )
        elsif is_letter?(char)
          tokens.push(
            Token.new(:identifier, read_string)
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

    def read_body_string
      string = ""

      while @content[@position] != "<"
        raise "unterminated content" if @position > @content.length
        string += @content[@position]
        @position += 1
      end

      string
    end

    def read_ruby_string
      inner_bracket_count = 0

      string = ""

      @position += 1

      loop do
        break if inner_bracket_count == 0 && @content[@position] == "}"
        char = @content[@position]
        string += char

        if char == "{"
          inner_bracket_count += 1
        elsif char == "}"
          inner_bracket_count -= 1
        end

        @position += 1
      end

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
