# frozen_string_literal: true

require "test_helper"

module ComponentEmbeddedRuby
  class LexerTest < Minitest::Test
    def test_that_it_lexes_basic_html
      lexer = Lexer.new("<html></html>")

      expected = [
        Lexer::Token.new(:open_carrot, "<"),
        Lexer::Token.new(:identifier, "html"),
        Lexer::Token.new(:close_carrot, ">"),
        Lexer::Token.new(:open_carrot, "<"),
        Lexer::Token.new(:slash, "/"),
        Lexer::Token.new(:identifier, "html"),
        Lexer::Token.new(:close_carrot, ">")
      ]

      assert_types_and_values_equal expected, lexer.lex
    end

    def test_that_it_parses_attributes
      lexer = Lexer.new('<html id="main"></html>')

      expected = [
        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:identifier, "html"),
        Lexer::Token.new(:identifier, "id"),
        Lexer::Token.new(:equals, nil),
        Lexer::Token.new(:string, "main"),
        Lexer::Token.new(:close_carrot, nil),
        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:slash, nil),
        Lexer::Token.new(:identifier, "html"),
        Lexer::Token.new(:close_carrot, nil)
      ]

      assert_types_and_values_equal expected, lexer.lex
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
        Lexer::Token.new(:close_carrot, nil)
      ]

      assert_types_and_values_equal expected, lexer.lex
    end

    def test_that_it_parses_quotes_correctly
      lexer = Lexer.new('<p name="hello >< \" world!"></p>')

      expected = [
        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:identifier, "p"),
        Lexer::Token.new(:identifier, "name"),
        Lexer::Token.new(:equals, nil),
        Lexer::Token.new(:string, 'hello >< \\" world!'),
        Lexer::Token.new(:close_carrot, nil),

        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:slash, nil),
        Lexer::Token.new(:identifier, "p"),
        Lexer::Token.new(:close_carrot, nil)
      ]

      assert_types_and_values_equal expected, lexer.lex
    end

    def test_text_is_parsed_correctly
      lexer = Lexer.new("<p>hello! this is !@#(*!^& content</p>")

      expected = [
        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:identifier, "p"),
        Lexer::Token.new(:close_carrot, nil),

        Lexer::Token.new(:string, "hello! this is !@#(*!^& content"),

        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:slash, nil),
        Lexer::Token.new(:identifier, "p"),
        Lexer::Token.new(:close_carrot, nil)
      ]

      assert_types_and_values_equal expected, lexer.lex
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
        Lexer::Token.new(:close_carrot, nil)
      ]

      assert_types_and_values_equal expected, lexer.lex
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
        Lexer::Token.new(:close_carrot, nil)
      ]

      assert_types_and_values_equal expected, lexer.lex
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
        Lexer::Token.new(:close_carrot, nil)
      ]

      assert_types_and_values_equal expected, lexer.lex
    end

    def test_handles_ruby_in_body_strings
      lexer = Lexer.new('<p>hello {"world!"}</p>')

      expected = [
        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:identifier, "p"),
        Lexer::Token.new(:close_carrot, nil),

        Lexer::Token.new(:string, "hello "),
        Lexer::Token.new(:ruby, '"world!"'),

        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:slash, nil),
        Lexer::Token.new(:identifier, "p"),
        Lexer::Token.new(:close_carrot, nil)
      ]

      assert_types_and_values_equal expected, lexer.lex
    end

    def test_handles_newlines_in_markup
      lexer = Lexer.new("<p>\nworld!</p>")

      expected = [
        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:identifier, "p"),
        Lexer::Token.new(:close_carrot, nil),

        Lexer::Token.new(:string, "world!"),

        Lexer::Token.new(:open_carrot, nil),
        Lexer::Token.new(:slash, nil),
        Lexer::Token.new(:identifier, "p"),
        Lexer::Token.new(:close_carrot, nil)
      ]

      assert_types_and_values_equal expected, lexer.lex
    end

    def test_handles_mixed_strings_in_ruby
      lexer = Lexer.new("{\"isn't ruby great?\"}")

      expected = [
        Lexer::Token.new(:ruby, '"isn\'t ruby great?"')
      ]

      assert_types_and_values_equal expected, lexer.lex
    end

    def assert_types_and_values_equal(expected_values, received_values)
      expected_values.zip(received_values).each do |expected, received|
        flunk "#{expected} != #{received}" if expected.type != received.type

        next unless expected.value != received.value &&
                    (expected.type == :string ||
                     expected.type == :identifier ||
                     expected.type == :ruby)

        flunk "#{expected} != #{received}"
      end
    end
  end
end
