require "test_helper"

module ComponentEmbeddedRuby
  class LexerTest < Minitest::Test
    def test_that_it_lexes_basic_html
      lexer = Lexer.new("<html></html>")

      expected = [
        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:identifier, "html"),
        Lexer::Token.new(:close_carrot, nil),
        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:slash, nil),
        Lexer::Token.new(:identifier, "html"),
        Lexer::Token.new(:close_carrot, nil),
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
        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:identifier, "html"),
        Lexer::Token.new(:identifier, "id"),
        Lexer::Token.new(:equals, nil),
        Lexer::Token.new(:string, "main"),
        Lexer::Token.new(:close_carrot, nil),
        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:slash, nil),
        Lexer::Token.new(:identifier, "html"),
        Lexer::Token.new(:close_carrot, nil),
      ], lexer.lex
    end

    def test_that_it_lexes_nested_html
      lexer = Lexer.new("<html><p></p></html>")

      expected = [
        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:identifier, "html"),
        Lexer::Token.new(:close_carrot, nil),

        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:identifier, "p"),
        Lexer::Token.new(:close_carrot, nil),

        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:slash, nil),
        Lexer::Token.new(:identifier, "p"),
        Lexer::Token.new(:close_carrot, nil),

        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:slash, nil),
        Lexer::Token.new(:identifier, "html"),
        Lexer::Token.new(:close_carrot, nil),
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
        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:identifier, "p"),
        Lexer::Token.new(:identifier, "name"),
        Lexer::Token.new(:equals, nil),
        Lexer::Token.new(:string, "hello >< \\\" world!"),
        Lexer::Token.new(:close_carrot, nil),

        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:slash, nil),
        Lexer::Token.new(:identifier, "p"),
        Lexer::Token.new(:close_carrot, nil),
      ]

      expected.zip(lexer.lex).each do |expected, received|
        if expected != received
          flunk "#{expected} != #{received}"
        end
      end
    end

    def test_text_is_parsed_correctly
      lexer = Lexer.new('<p>hello! this is !@#(*!^& content</p>')

      expected = [
        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:identifier, "p"),
        Lexer::Token.new(:close_carrot, nil),

        Lexer::Token.new(:string, "hello! this is !@#(*!^& content"),

        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:slash, nil),
        Lexer::Token.new(:identifier, "p"),
        Lexer::Token.new(:close_carrot, nil),
      ]

      expected.zip(lexer.lex).each do |expected, received|
        if expected != received
          flunk "#{expected} != #{received}"
        end
      end
    end
  end
end
