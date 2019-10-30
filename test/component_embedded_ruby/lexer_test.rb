require "test_helper"

module ComponentEmbeddedRuby
  class LexerTest < Minitest::Test
    def test_that_it_lexes_basic_html
      lexer = Lexer.new("<html></html>")

      assert_equal [
        Lexer::Token.new(Lexer::TOKEN_OPEN_CARROT, nil),
        Lexer::Token.new(Lexer::TOKEN_STRING, "html"),
        Lexer::Token.new(Lexer::TOKEN_CLOSE_CARROT, nil),
        Lexer::Token.new(Lexer::TOKEN_OPEN_CARROT, nil),
        Lexer::Token.new(Lexer::TOKEN_SLASH, nil),
        Lexer::Token.new(Lexer::TOKEN_STRING, "html"),
        Lexer::Token.new(Lexer::TOKEN_CLOSE_CARROT, nil),
      ], lexer.parse
    end

    def test_that_it_parses_attributes
      lexer = Lexer.new('<html id="main"></html>')

      assert_equal [
        Lexer::Token.new(Lexer::TOKEN_OPEN_CARROT, nil),
        Lexer::Token.new(Lexer::TOKEN_STRING, "html"),
        Lexer::Token.new(Lexer::TOKEN_STRING, "id"),
        Lexer::Token.new(Lexer::TOKEN_EQUALS, nil),
        Lexer::Token.new(Lexer::TOKEN_QUOTE, nil),
        Lexer::Token.new(Lexer::TOKEN_STRING, "main"),
        Lexer::Token.new(Lexer::TOKEN_QUOTE, nil),
        Lexer::Token.new(Lexer::TOKEN_CLOSE_CARROT, nil),
        Lexer::Token.new(Lexer::TOKEN_OPEN_CARROT, nil),
        Lexer::Token.new(Lexer::TOKEN_SLASH, nil),
        Lexer::Token.new(Lexer::TOKEN_STRING, "html"),
        Lexer::Token.new(Lexer::TOKEN_CLOSE_CARROT, nil),
      ], lexer.parse
    end
  end
end
