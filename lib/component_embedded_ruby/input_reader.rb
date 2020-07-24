module ComponentEmbeddedRuby
  class InputReader
    attr_reader :current_line, :current_column

    def initialize(input)
      @input = input.freeze
      @position = 0

      @current_line = 0
      @current_column = 0
    end

    def eof?
      @position == @input.length
    end

    def current_char
      input[@position]
    end

    def peek
      @input[@position + 1]
    end

    def peek_behind
      @input[@position - 1]
    end

    def next
      if current_char == "\n"
        @current_line += 1
        @current_column = 0
      else
        @current_column += 1
      end

      @position += 1
    end

    private

    attr_reader :input
  end
end
