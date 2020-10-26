# frozen_string_literal: true

require "component_embedded_ruby/lexer/input_reader"
require "component_embedded_ruby/lexer/string_reader"
require "component_embedded_ruby/lexer/ruby_code_reader"

module ComponentEmbeddedRuby
  class Lexer
    Token = Struct.new(:type, :value, :position)
    Position = Struct.new(:line, :column)

    def initialize(content)
      @reader = InputReader.new(content)

      @tokens = []
    end

    def lex # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      while !reader.eof?
        char = reader.current_char

        if char == "<"
          add_token(:open_carrot, "<")
          reader.next
        elsif char == ">"
          add_token(:close_carrot, ">")
          reader.next
        elsif char == "="
          add_token(:equals, "=")
          reader.next
        elsif char == '"'
          add_token(:string, read_quoted_string)
        elsif char == "/"
          add_token(:slash, "/")
          reader.next
        elsif char == "{"
          if reader.peek == "-"
            reader.next
            add_token(:ruby_no_eval, read_ruby_string)
          else
            add_token(:ruby, read_ruby_string)
          end
        elsif letter?(char)
          position = Position.new(reader.current_line, reader.current_column)

          if @tokens[-1]&.type == :close_carrot
            add_token(:string, read_body_string, position)
          else
            add_token(:identifier, read_string, position)
          end
        else
          reader.next
        end
      end

      @tokens
    end

    private

    attr_reader :reader

    def add_token(type, value, position = Position.new(reader.current_line, reader.current_column))
      token = Token.new(type, value, position)
      @tokens << token
    end

    def read_string
      string = ""

      while letter?(reader.current_char) && !reader.eof?
        string += reader.current_char
        reader.next
      end

      string
    end

    def read_quoted_string
      string = ""

      # Get past initial "
      reader.next

      while !unescaped_quote?
        raise "unterminated string" if reader.eof?

        string += reader.current_char
        reader.next
      end

      # Get past last "
      reader.next

      string
    end

    def read_body_string
      string = ""

      while reader.current_char != "<" && reader.current_char != "{"
        raise "unterminated content" if reader.eof?

        string += reader.current_char
        reader.next
      end

      string
    end

    def read_ruby_string
      RubyCodeReader.new(reader).read_until_closing_tag
    end

    def unescaped_quote?
      reader.current_char == '"' && reader.peek_behind != '\\'
    end

    def letter?(char)
      ascii = char.ord
      (ascii >= 48 && ascii <= 57) || (ascii >= 65 && ascii <= 122) || ascii == 45 || ascii == 95 || ascii == 58
    end
  end
end
