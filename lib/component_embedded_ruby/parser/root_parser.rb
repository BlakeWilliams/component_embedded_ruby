# frozen_string_literal: true

module ComponentEmbeddedRuby
  module Parser
    # Internal: Used for parsing multiple adjacent tag, string, and emedded
    # ruby into an array.
    #
    # This parser is used to parse top-level documents and the children of
    # `tag` nodes, which may have any combination of adjacent tag, string, and
    # ruby nodes.
    #
    class RootParser < Base
      def call
        results = []

        while current_token
          case current_token.type
          when :open_carrot
            # If we run into a </ we are likely at the end of parsing a tag so
            # this should return and let the `TagParser` complete parsing
            #
            # e.g.
            # 1. <h1>Hello</h1> would start a `TagParser` after reading <h1
            # 2. `TagParser` reads <h1>, sees that it has
            #     children, and will use another instance of `RootParser` to reads its children
            # 3. The new RootParser reads `Hello`, then runs into `</`, so it should return `["Hello"]`
            #     and allow the `TagParser` to finish reading `</h1>`
            return results if peek_token.type == :slash

            results << TagParser.new(token_reader).call
          when :string, :identifier
            # If we're reading a string, or some other identifier that is on
            # its own, we can skip instantiating a new parser and parse it directly ourselves
            results << Node.new(nil, nil, current_token.value)
            token_reader.next
          when :ruby, :ruby_no_eval
            # If we run into Ruby code that should be evaluated inside of the
            # template, we want to create an `Eval`. The compliation step
            # handles `Eval` objects specially since it's making template
            # provided ruby code compatibile with the compiled template code.
            value = Eval.new(current_token.value, output: current_token.type == :ruby)

            results << Node.new(nil, nil, value)
            token_reader.next
          end
        end

        results
      end
    end
  end
end
