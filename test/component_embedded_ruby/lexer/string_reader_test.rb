# frozen_string_literal: true

require "test_helper"

module ComponentEmbeddedRuby
  class LexerStringReaderTest < Minitest::Test
    def test_basic_string
      reader = input_reader_for('{"hello world"}')

      result = Lexer::RubyCodeReader.new(reader).read_until_closing_tag

      assert_equal '"hello world"', result
    end

    def test_empty_string
      reader = input_reader_for('{""}')

      result = Lexer::RubyCodeReader.new(reader).read_until_closing_tag

      assert_equal '""', result
    end

    def test_double_quoted_string_with_single_quote
      reader = input_reader_for(%q[{"isn't ruby great?"}])

      result = Lexer::RubyCodeReader.new(reader).read_until_closing_tag

      assert_equal %q["isn't ruby great?"], result
    end

    def test_parses_hash
      reader = input_reader_for(%q[{{ key: value }}])

      result = Lexer::RubyCodeReader.new(reader).read_until_closing_tag

      assert_equal %q[{ key: value }], result
    end

    def test_parses_nested_hash
      reader = input_reader_for(%q[{{ key: { a: { b: 1 } } }}])

      result = Lexer::RubyCodeReader.new(reader).read_until_closing_tag

      assert_equal %q[{ key: { a: { b: 1 } } }], result
    end

    def test_handles_bracket_in_string
      reader = input_reader_for(%q[{"isn't ruby { great?"}])

      result = Lexer::RubyCodeReader.new(reader).read_until_closing_tag

      assert_equal %q["isn't ruby { great?"], result
    end

    def test_parses_interpolated_ruby
      reader = input_reader_for(%q[{"hello #{""}"}])

      result = Lexer::RubyCodeReader.new(reader).read_until_closing_tag

      assert_equal %q["hello #{""}"], result
    end

    def test_parses_nested_interpolated_ruby
      reader = input_reader_for(%q[{"hello #{"{"}"}])

      result = Lexer::RubyCodeReader.new(reader).read_until_closing_tag

      assert_equal %q["hello #{"{"}"], result
    end

    def input_reader_for(input)
      Lexer::InputReader.new(input)
    end
  end
end
