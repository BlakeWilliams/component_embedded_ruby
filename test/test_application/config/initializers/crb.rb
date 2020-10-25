class CrbTemplateHandler
  def self.call(template, template_source)
    template = ComponentEmbeddedRuby::Template.new(template_source)
    template.to_ruby
  end
end

ActionView::Template.register_template_handler(
  :crb,
  CrbTemplateHandler
)
