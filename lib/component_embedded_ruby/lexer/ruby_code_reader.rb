# frozen_string_literal: true

module ComponentEmbeddedRuby
  class Lexer
    class RubyCodeReader
      def initialize(input_reader)
        @input_reader = input_reader
      end

      def read_until_closing_tag
        string = ""

        loop do
          input_reader.next
          current_char = input_reader.current_char

          break if current_char == "}"

          string += current_char

          if current_char == "{"
            string += RubyCodeReader.new(input_reader).read_until_closing_tag

            # RubyCodeReader reads until "}", so we have to re-add that
            # character when reading nested code
            string += "}"
          elsif current_char == "'" || current_char == '"'
            # TODO: this *may* need to handle % syntax strings too
            string += StringReader.new(
              input_reader,
              quote_type: current_char,
              can_interpolate: current_char == '"'
            ).read_until_closing_quote
          end
        end

        string
      end

      private

      attr_reader :input_reader
    end
  end
end
