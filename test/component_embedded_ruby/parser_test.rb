# frozen_string_literal: true

require "test_helper"

module ComponentEmbeddedRuby
  class ParserTest < Minitest::Test
    def test_it_parses_basic_html
      lexer = Lexer.new("<html></html>")
      results = Parser.parse(lexer.lex)

      expected = Node.new(
        "html",
        {},
        []
      )

      assert_equal expected, results.first
    end

    def test_parses_multiple_children
      lexer = Lexer.new("<header></header><footer></footer>")
      results = Parser.parse(lexer.lex)

      expected = [
        Node.new("header", {}, []),
        Node.new("footer", {}, [])
      ]

      assert_equal expected, results
    end

    def test_it_parses_nested_html
      lexer = Lexer.new("<html><p></p></html>")
      results = Parser.parse(lexer.lex)

      expected = Node.new(
        "html",
        {},
        [
          Node.new("p", {}, [])
        ]
      )

      assert_equal expected, results.first
    end

    def test_it_parses_adjacent_html
      lexer = Lexer.new("<html><p></p><b></b></html>")
      results = Parser.parse(lexer.lex)

      expected = Node.new(
        "html",
        {},
        [
          Node.new("p", {}, []),
          Node.new("b", {}, [])
        ]
      )

      assert_equal expected, results.first
    end

    def test_it_parses_string_content_as_children
      lexer = Lexer.new("<b>Hello world</b>")
      results = Parser.parse(lexer.lex)

      expected = Node.new(
        "b",
        {},
        [
          Node.new(nil, nil, "Hello world")
        ]
      )

      assert_equal expected, results.first
    end

    def test_it_parses_html_attributes
      lexer = Lexer.new('<b id="rad">Hello world</b>')
      results = Parser.parse(lexer.lex)

      expected = Node.new(
        "b",
        { "id" => "rad" },
        [
          Node.new(nil, nil, "Hello world")
        ]
      )

      assert_equal expected, results.first
    end

    def test_parses_self_closing_tags
      lexer = Lexer.new('<div><img src="#"/></div>')
      results = Parser.parse(lexer.lex)

      expected = Node.new(
        "div",
        {},
        [
          Node.new("img", { "src" => "#" }, [])
        ]
      )

      assert_equal expected, results.first
    end

    def test_parses_eval_attributes
      lexer = Lexer.new("<b id={rad}></b>")
      results = Parser.parse(lexer.lex)

      expected = Node.new(
        "b",
        { "id" => Eval.new("rad") },
        []
      )

      assert_equal expected, results.first
    end

    def test_unexpected_any_token_raises
      lexer = Lexer.new("<b id=1></b>")

      Node.new(
        "b",
        { "id" => Eval.new("rad") },
        []
      )

      exception = assert_raises UnexpectedTokenError do
        Parser.parse(lexer.lex)
      end

      # TODO: these could turn into very descriptive, and helpful errors
      assert_equal "Unexpected token at line 1, column 7\nGot `1` but expected a string or ruby code", exception.message
    end

    def test_unexpected_token_raises
      lexer = Lexer.new("<b</b>")

      Node.new(
        "b",
        { "id" => Eval.new("rad") },
        []
      )

      exception = assert_raises UnexpectedTokenError do
        Parser.parse(lexer.lex)
      end

      assert_equal "Unexpected token at line 1, column 3\nGot `<` but expected `>`", exception.message
    end
  end
end
