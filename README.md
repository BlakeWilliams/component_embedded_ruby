# Component Embedded Ruby

Strict HTML templating with support for components.

### Features:

* Strict HTML parsing. eg: matching end tags are enforced
* HTML attributes are either static, or dynamic. No more `class="hello <%=
    extra_classes %>`, instead this logic should be pushed up to components.
* Component rendering has a single dependency, a `render` method being present
  in the rendering context.
* Rails support

### Usage

Define a template:

```ruby
<h1>
  <Capitalization upcase={true}>hello world</Capitalization>
</h1>
```

Define a component

```ruby
class Capitalization
  def initialize(upcase: false)
    @upcase = upcase
  end

  def render_in(_view_context)
    children = yield

    if @upcase
      children.upcase
    else
      children
    end
  end
end
```

Render it

```ruby
ComponentEmbeddedRuby.render(template_string)
```

See results


```html
<h1>HELLO WORLD</h1>
```

If trying to render outside of a Rails environment, ensure that the binding
passed to the renderer has a top-level `render` method that can accept component
instances and convert them to strings.


e.g. the most basic example could look like this:

```ruby
def render(renderable, &block)
  # This assumes components being rendered utilize `to_s` to render their
  # templates
  renderable.to_s(&block)
end
```

For more examples, check out the `ComponentEmbeddedRuby::Renderable` tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/BlakeWilliams/component_embedded_ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
