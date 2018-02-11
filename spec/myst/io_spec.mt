require "stdlib/spec.mt"


describe("IO#read") do
  it("raises an error if not implemented by a subtype") do
    expect_raises{ %IO{}.read(1) }
  end
end


describe("IO#write") do
  it("raises an error if not implemented by a subtype") do
    expect_raises{ %IO{}.write("content") }
  end
end



# MockIO implements `read` and `write` with String buffers to allow for testing
# various methods directly on IO without relying on external resources like
# STDOUT or Files.
deftype MockIO : IO
  def initialize
    @read_content = ""
    @write_content = ""
    @read_position = 0
  end

  def initialize(@read_content : String)
    @write_content = ""
    @read_position = 0
  end

  def initialize(@read_content : String, @write_content : String)
    @read_position = 0
  end

  def write_content; @write_content; end

  def read(length : Integer)
    content = @read_content[@read_position, length]
    @read_position += length
    content
  end

  def write(content : String)
    @write_content += content
  end
end


describe("IO#puts") do
  describe("with no arguments") do
    it("outputs a single newline character") do
      io = %MockIO{}

      io.puts
      assert(io.write_content == "\n")
    end
  end

  describe("with one argument") do
    it("calls `to_s` on the argument") do
      deftype Foo
        def called_to_s; @called_to_s; end
        def to_s
          @called_to_s = true
          "foo"
        end
      end

      io = %MockIO{}
      foo = %Foo{}
      io.puts(foo)
      assert(foo.called_to_s == true)
    end

    it("outputs the stringified argument, followed by a newline character") do
      io = %MockIO{}
      io.puts("hello, world!")
      assert(io.write_content == "hello, world!\n")
    end
  end

  describe("with multiple arguments") do
    it("accepts arguments with different types") do
      io = %MockIO{}
      io.puts(1, false, :hello)
    end

    it("outputs each argument in order") do
      io = %MockIO{}
      io.puts(1, 2, 3)

      assert(io.write_content == "1\n2\n3\n")
    end
  end
end


describe("IO#print") do
  it("calls `to_s` on the argument") do
    deftype Foo
      def called_to_s; @called_to_s; end
      def to_s
        @called_to_s = true
        "foo"
      end
    end

    io = %MockIO{}
    foo = %Foo{}
    io.print(foo)
    assert(foo.called_to_s == true)
  end

  it("outputs the stringified argument") do
    io = %MockIO{}
    io.print("hello, world!")
    assert(io.write_content == "hello, world!")
  end
end

describe("IO#gets") do
  it("reads characters from the IO until a newline character is found") do
    io = %MockIO{"hello\nworld"}
    content = io.gets
    assert(content == "hello")
  end

  it("reads through the entire IO if no newline character is found") do
    io = %MockIO{"this buffer content does not contain newlines"}
    content = io.gets

    assert(content == "this buffer content does not contain newlines")
  end

  it("returns an empty string if the next character is a newline") do
    io = %MockIO{"\n"}
    content = io.gets

    assert(content == "")
  end
end
