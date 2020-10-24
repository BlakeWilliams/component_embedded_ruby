class HelloRenderable
  def initialize(name:)
    @name = name
  end

  def render_in(*args)
    "<p>Hello from #{@name}</p>"
  end
end
