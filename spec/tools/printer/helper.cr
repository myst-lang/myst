require "../../spec_helper.cr"
require "../../support/nodes.cr"

require "../../../src/myst/tools/printer.cr"


def assert_print(source, expected=nil)
  # If no source is given, the output should be expected to match the input
  # without modification.
  expected ||= source

  it "prints `#{source}` as `#{expected}`" do
    io = IO::Memory.new
    program = parse_program(source)
    printer = Myst::Printer.new(output: io)
    printer.print(program)

    io.to_s.should eq(expected)
  end
end
