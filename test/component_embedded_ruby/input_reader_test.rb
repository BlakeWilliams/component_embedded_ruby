require "test_helper"

module ComponentEmbeddedRuby
  class LexerInputReaderTest < Minitest::Test
    def test_input_reading
      reader = Lexer::InputReader.new("hello\nworld\nrad")

      assert_equal 1, reader.current_line
      assert_equal 1, reader.current_column

      # we start on "h"
      # read "ello\n"
      5.times { reader.next }

      assert_equal "\n", reader.current_char
      assert_equal 1, reader.current_line
      assert_equal 6, reader.current_column

      # read world\n
      6.times { reader.next }

      assert_equal "\n", reader.current_char
      assert_equal 2, reader.current_line
      assert_equal 6, reader.current_column

      4.times { reader.next }

      assert_equal 3, reader.current_line
      assert_equal 4, reader.current_column
    end
  end
end
