class CrbTemplateHandler
  def self.call(template, source)
    ComponentEmbeddedRuby.to_source(source)
  end
end

ActionView::Template.register_template_handler(
  :crb,
  CrbTemplateHandler
)
