# Module style is taken directly from Ruby. Module names should be written in
# UpperCamelCase, with abbreviations fully capitalized (i.e., `HTTPServer`).
#
# Note: the namespacing shorthand introduced later in Ruby is not yet
# supported. Module names like `IO::Buffered` will result in a syntax error.
module IO
  STDIN = 0
  STDOUT = 1
  STDERR = 2

  def read(count)
    "h" * count
  end

  def write(data)
    # `_mt_write` is a native functor for writing to file descriptors. In most
    # cases it should be avoided, as the standard library provides `IO.puts`
    # and other interfaces around it.
    _mt_write(STDOUT, data+"\n")
  end

  module Nested
    def test(data)
      write(data)
    end
  end
end

# Module usage is also taken directly from Ruby.
#
# This example "reads" 10 characters from the IO, then outputs them to the
# standard output.
text = IO.read(10)
IO.write(text)

IO.Nested.test(text*2)
