# frozen_string_literal: true

module ComponentEmbeddedRuby
  class RailsHandler
    def self.call(template, source = nil)
      source ||= template.source

      Template.new(source).to_ruby
    end
  end
end

ActionView::Template.register_template_handler(:crb, ComponentEmbeddedRuby::RailsHandler)
