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

    def current_token
      content[@position]
    end

    def read_string
      string = ""

      while is_letter?(current_token) && @position < @content.length
        string += current_token
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
        string += current_token
        @position += 1
      end

      # Get past last "
      @position += 1

      string
    end

    def read_body_string
      string = ""

      while current_token != "<"
        raise "unterminated content" if @position > @content.length
        string += current_token
        @position += 1
      end

      string
    end

    def read_ruby_string
      inner_string_count = 0
      inner_bracket_count = 0

      string = ""

      @position += 1

      previous_token = nil

      loop do
        break if inner_bracket_count == 0 && inner_string_count % 2 == 0 && current_token == "}"
        char = current_token
        string += char

        # TODO handle " and ' separately
        if inner_string_count % 2 == 0 && char == "{"
          inner_bracket_count += 1
        elsif inner_string_count % 2 == 0 && char == "}"
          inner_bracket_count -= 1
        elsif previous_token != "\\" && char == "\"" || char == "'"
          inner_string_count -= 1
        end

        previous_token = char
        @position += 1
      end

      string
    end

    def unescaped_quote?
      current_token == "\"" && @content[@position -1] != "\\"
    end

    def is_letter?(char)
      ascii = char.ord
      (ascii >= 48 && ascii <= 57) || (ascii >= 65 && ascii <= 122) || ascii == 45 || ascii == 95
    end
  end
end
