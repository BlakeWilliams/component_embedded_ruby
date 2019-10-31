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

    def test_ruby_is_parsed_correctly
      lexer = Lexer.new('<p name={generated_name}>{"world!"}</p>')

      expected = [
        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:identifier, "p"),
        Lexer::Token.new(:identifier, "name"),
        Lexer::Token.new(:equals, nil),
        Lexer::Token.new(:ruby, "generated_name"),
        Lexer::Token.new(:close_carrot, nil),

        Lexer::Token.new(:ruby, '"world!"'),

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

    def test_ruby_is_parsed_correctly_with_inner_hash
      lexer = Lexer.new('<p name={{ "hello" => "world" }.keys}>{"world!"}</p>')

      expected = [
        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:identifier, "p"),
        Lexer::Token.new(:identifier, "name"),
        Lexer::Token.new(:equals, nil),
        Lexer::Token.new(:ruby, '{ "hello" => "world" }.keys'),
        Lexer::Token.new(:close_carrot, nil),

        Lexer::Token.new(:ruby, '"world!"'),

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

    def test_handles_strings_in_ruby
      lexer = Lexer.new('<p name={{ "hello}" => "world" }.keys}>{"world!"}</p>')

      expected = [
        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:identifier, "p"),
        Lexer::Token.new(:identifier, "name"),
        Lexer::Token.new(:equals, nil),
        Lexer::Token.new(:ruby, '{ "hello}" => "world" }.keys'),
        Lexer::Token.new(:close_carrot, nil),

        Lexer::Token.new(:ruby, '"world!"'),

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

    def test_handles_newlines_in_markup
      lexer = Lexer.new("<p>\nworld!</p>")

      expected = [
        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:identifier, "p"),
        Lexer::Token.new(:close_carrot, nil),

        Lexer::Token.new(:string, 'world!'),

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
