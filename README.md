# Component Embedded Ruby

Strict HTML templating with support for components.

### Features:

* Strict HTML parsing. eg: matching end tags are enforced
* HTML attributes are either static, or dynamic. No more `class="hello <%=
    extra_classes %>`
* Component rendering based on a simple interface

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

  def render_in
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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/BlakeWilliams/component_embedded_ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
