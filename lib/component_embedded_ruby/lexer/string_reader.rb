# frozen_string_literal: true

module ComponentEmbeddedRuby
  class Lexer
    class StringReader
      def initialize(input_reader, quote_type:, can_interpolate:)
        @input_reader = input_reader
        @quote_type = quote_type
        @can_interpolate = can_interpolate
      end

      def read_until_closing_quote
        string = ""

        previous_char = nil
        current_char = input_reader.current_char

        loop do
          input_reader.next
          previous_char = current_char
          current_char = input_reader.current_char

          string += current_char
          break if current_char == quote_type && string[-1] != "\\"

          if can_interpolate && string[-2..-1] == '#{' && string[-3] != "\\"
            string += RubyCodeReader.new(input_reader).read_until_closing_tag
            string += "}"
          end
        end

        string
      end

      private

      attr_reader :input_reader, :quote_type, :can_interpolate
    end
  end
end
