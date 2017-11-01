require "../../spec_helper.cr"
require "../../support/nodes.cr"

require "../../../src/myst/tools/printer.cr"


# Assert that the result of parsing and printing the given source code matches
# the expected String. If no expected value is given, use the source itself as
# the expected output.
def assert_print(source : String, expected : String?=nil, file=__FILE__, line=__LINE__, end_line=__END_LINE__)
  expected ||= source

  it "prints `#{source}` as `#{expected}`", file, line, end_line do
    io = IO::Memory.new
    program = parse_program(source)
    printer = Myst::Printer.new(output: io)
    printer.print(program)

    io.to_s.should eq(expected)
  end
end

# Assert that the printer is able to print the given node. If `expected` is
# given, assert that the output of the printer matches it. If not, no
# assertion is made on the output.
def assert_print(node : Node, expected : String?=nil, file=__FILE__, line=__LINE__, end_line=__END_LINE__)
  test_name = "prints `#{node.inspect}`"
  test_name += " as `#{expected}`" if expected

  it test_name, file, line, end_line do
    io = IO::Memory.new
    printer = Myst::Printer.new(output: io)
    printer.print(node)

    if expected
      io.to_s.should eq(expected)
    end
  end
end
