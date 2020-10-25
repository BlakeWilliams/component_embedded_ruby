module ComponentEmbeddedRuby
  class Parser
    class RootParser < Base
      def parse(inside_tag: false)
        results = []

        while current_token
          case current_token.type
          when :open_carrot
            if peek_token.type == :slash # close tag
              if inside_tag
                return results
              else
                nil
              end
            else
              results << TagParser.new(@token_reader).call
            end
          when :string, :identifier
            results << Node.new(nil, nil, current_token.value).tap do
              @token_reader.next
            end
          when :ruby, :ruby_no_eval
            value = Eval.new(current_token.value, output: current_token.type == :ruby)

            results << Node.new(nil, nil, value).tap do
              @token_reader.next
            end
          else
            if inside_tag
              return results
            end
          end
        end

        results
      end
    end
  end
end
