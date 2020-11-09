# frozen_string_literal: true

module ComponentEmbeddedRuby
  class RailsHandler
    def self.call(template, source = nil)
      source ||= template.source

      template_source = Template.new(
        source,
        safe_append_method: "safe_append=",
        unsafe_append_method: "append=",
        output_var_name: "@output_buffer"
      ).to_ruby

      <<~RUBY
        @output_buffer = ActionView::OutputBuffer.new('')
        #{template_source}
      RUBY
    end
  end
end

ActionView::Template.register_template_handler(:crb, ComponentEmbeddedRuby::RailsHandler)
