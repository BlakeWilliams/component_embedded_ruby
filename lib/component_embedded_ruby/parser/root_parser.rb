module ComponentEmbeddedRuby
  class Parser
    class RootParser < Base
      def call
        results = []

        while current_token
          if current_token.type == :open_carrot
            # If we run into a </ we have are likely at the end of parsing a tag
            # so this should return and let the `TagParser` complete parsing
            #
            # e.g.
            # 1. <h1>Hello</h1> would start a `TagParser` after reading <h1
            # 2. `TagParser` reads <h1>, sees that it has
            #     children, and will use another instance of `RootParser` to reads its children
            # 3. The new RootParser reads `Hello`, then runs into `</`, so it should return `["Hello"]`
            #     and allow the `TagParser` to finish reading `</h1>`
            if peek_token.type == :slash
              return results
            else
              results << TagParser.new(@token_reader).call
            end
          elsif current_token.type == :string || current_token.type == :identifier
            # If we're reading a string, or some other identifier that is on
            # its own, we can skip instantiating a new parser and parse it directly ourselves
            results << Node.new(nil, nil, current_token.value).tap do
              @token_reader.next
            end
          elsif current_token.type == :ruby || current_token.type == :ruby_no_eval
            # If we run into Ruby code that should be evaluated inside of the
            # template, we want to create an `Eval`. The compliation step
            # handles `Eval` objects specially since it's making template
            # provided ruby code compatibile with the compiled template code.
            value = Eval.new(current_token.value, output: current_token.type == :ruby)

            results << Node.new(nil, nil, value).tap do
              @token_reader.next
            end
          end
        end

        results
      end
    end
  end
end
