require "test_helper"

module ComponentEmbeddedRuby
  class ParserTest < Minitest::Test
    def test_it_parses_basic_html
      lexer = Lexer.new("<html></html>")
      results = Parser.new(lexer.lex).parse

      expected = {
        tag: "html",
        attributes: [],
        children: []
      }

      assert_equal expected, results
    end

    def test_it_parses_nested_html
      lexer = Lexer.new("<html><p></p></html>")
      results = Parser.new(lexer.lex).parse

      expected = {
        tag: "html",
        attributes: [],
        children: [
          {
            tag: "p",
            attributes: [],
            children: []
          }
        ]
      }

      assert_equal expected, results
    end

    def test_it_parses_adjacent_html
      lexer = Lexer.new("<html><p></p><b></b></html>")
      results = Parser.new(lexer.lex).parse

      expected = {
        tag: "html",
        attributes: [],
        children: [
          {
            tag: "p",
            attributes: [],
            children: []
          },
          {
            tag: "b",
            attributes: [],
            children: []
          }
        ]
      }

      assert_equal expected, results
    end

    def test_it_parses_string_content_as_children
      lexer = Lexer.new("<b>Hello world</b>")
      results = Parser.new(lexer.lex).parse

      expected = {
        tag: "b",
        attributes: [],
        children: [
          {
            tag: nil,
            attributes: nil,
            children: "Hello world"
          }
        ]
      }
    end

    def test_it_parses_html_attributes
      lexer = Lexer.new('<b id="rad">Hello world</b>')
      results = Parser.new(lexer.lex).parse

      expected = {
        tag: "b",
        attributes: [{ key: "id", value: "rad" }],
        children: []
      }
    end
  end
end
