# Module style is taken directly from Ruby. Module names should be written in
# UpperCamelCase, with abbreviations fully capitalized (i.e., `HTTPServer`).
#
# Note: the namespacing shorthand introduced later in Ruby is not yet
# supported. Module names like `IO::Buffered` will result in a syntax error.
module SampleIO
  STDIN = 0
  STDOUT = 1
  STDERR = 2

  def read(count)
    "h" * count
  end

  def puts(data)
    IO.puts(data)
  end

  module Nested
    def test(data)
      puts(data)
    end
  end
end

# Module usage is also taken directly from Ruby.
#
# This example "reads" 10 characters from the IO, then outputs them to the
# standard output.
text = SampleIO.read(10)
SampleIO.puts(text)

SampleIO.Nested.test(text*2)
