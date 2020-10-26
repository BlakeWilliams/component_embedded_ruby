# frozen_string_literal: true

module ComponentEmbeddedRuby
  class Lexer
    class StringReader
      def initialize(input_reader)
        @reader = input_reader
      end

      def read_until_closing_quote
        string = ""

        previous_char = nil
        current_char = input_reader.current_char
        input_reader.next

        loop do
          previous_char = current_char
          current_char = input_reader.current_char

          break if current_char == "'" && previous_char != "\\"

          string += current_char

          input_reader.next
        end

        return string
      end

      private

      attr_reader :reader
    end
  end
end
