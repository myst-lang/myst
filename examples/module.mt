# Module style is taken directly from Ruby. Module names should be written in
# UpperCamelCase, with abbreviations fully capitalized (i.e., `HTTPServer`).
#
# Note: the namespacing shorthand introduced later in Ruby is not yet
# supported. Module names like `IO::Buffered` will result in a syntax error.
module IO
  def read(count)
    "h" * count
  end

  def write(data)
    # TODO: later
  end
end

# Module usage is also taken directly from Ruby.
text = IO.read(10)
IO.write(text)

IO.read(10)[2]
