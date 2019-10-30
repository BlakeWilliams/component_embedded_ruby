require "test_helper"

module ComponentEmbeddedRuby
  class LexerTest < Minitest::Test
    def test_that_it_lexes_basic_html
      lexer = Lexer.new("<html></html>")

      expected = [
        Lexer::Token.new(Lexer::TOKEN_OPEN_CARROT, nil),
        Lexer::Token.new(Lexer::TOKEN_STRING, "html"),
        Lexer::Token.new(Lexer::TOKEN_CLOSE_CARROT, nil),
        Lexer::Token.new(Lexer::TOKEN_OPEN_CARROT, nil),
        Lexer::Token.new(Lexer::TOKEN_SLASH, nil),
        Lexer::Token.new(Lexer::TOKEN_STRING, "html"),
        Lexer::Token.new(Lexer::TOKEN_CLOSE_CARROT, nil),
      ]

      expected.zip(lexer.lex).each do |expected, received|
        if expected != received
          flunk "#{expected} != #{received}"
        end
      end
    end

    def test_that_it_parses_attributes
      lexer = Lexer.new('<html id="main"></html>')

      assert_equal [
        Lexer::Token.new(Lexer::TOKEN_OPEN_CARROT, nil),
        Lexer::Token.new(Lexer::TOKEN_STRING, "html"),
        Lexer::Token.new(Lexer::TOKEN_STRING, "id"),
        Lexer::Token.new(Lexer::TOKEN_EQUALS, nil),
        Lexer::Token.new(Lexer::TOKEN_STRING, "main"),
        Lexer::Token.new(Lexer::TOKEN_CLOSE_CARROT, nil),
        Lexer::Token.new(Lexer::TOKEN_OPEN_CARROT, nil),
        Lexer::Token.new(Lexer::TOKEN_SLASH, nil),
        Lexer::Token.new(Lexer::TOKEN_STRING, "html"),
        Lexer::Token.new(Lexer::TOKEN_CLOSE_CARROT, nil),
      ], lexer.lex
    end

    def test_that_it_lexes_nested_html
      lexer = Lexer.new("<html><p></p></html>")

      expected = [
        Lexer::Token.new(Lexer::TOKEN_OPEN_CARROT, nil),
        Lexer::Token.new(Lexer::TOKEN_STRING, "html"),
        Lexer::Token.new(Lexer::TOKEN_CLOSE_CARROT, nil),

        Lexer::Token.new(Lexer::TOKEN_OPEN_CARROT, nil),
        Lexer::Token.new(Lexer::TOKEN_STRING, "p"),
        Lexer::Token.new(Lexer::TOKEN_CLOSE_CARROT, nil),

        Lexer::Token.new(Lexer::TOKEN_OPEN_CARROT, nil),
        Lexer::Token.new(Lexer::TOKEN_SLASH, nil),
        Lexer::Token.new(Lexer::TOKEN_STRING, "p"),
        Lexer::Token.new(Lexer::TOKEN_CLOSE_CARROT, nil),

        Lexer::Token.new(Lexer::TOKEN_OPEN_CARROT, nil),
        Lexer::Token.new(Lexer::TOKEN_SLASH, nil),
        Lexer::Token.new(Lexer::TOKEN_STRING, "html"),
        Lexer::Token.new(Lexer::TOKEN_CLOSE_CARROT, nil),
      ]

      expected.zip(lexer.lex).each do |expected, received|
        if expected != received
          flunk "#{expected} != #{received}"
        end
      end
    end

    def test_that_it_parses_quotes_correctly
      lexer = Lexer.new('<p name="hello >< \" world!"></p>')

      expected = [
        Lexer::Token.new(Lexer::TOKEN_OPEN_CARROT, nil),
        Lexer::Token.new(Lexer::TOKEN_STRING, "p"),
        Lexer::Token.new(Lexer::TOKEN_STRING, "name"),
        Lexer::Token.new(Lexer::TOKEN_EQUALS, nil),
        Lexer::Token.new(Lexer::TOKEN_STRING, "hello >< \\\" world!"),
        Lexer::Token.new(Lexer::TOKEN_CLOSE_CARROT, nil),

        Lexer::Token.new(Lexer::TOKEN_OPEN_CARROT, nil),
        Lexer::Token.new(Lexer::TOKEN_SLASH, nil),
        Lexer::Token.new(Lexer::TOKEN_STRING, "p"),
        Lexer::Token.new(Lexer::TOKEN_CLOSE_CARROT, nil),
      ]

      expected.zip(lexer.lex).each do |expected, received|
        if expected != received
          flunk "#{expected} != #{received}"
        end
      end
    end
  end
end
