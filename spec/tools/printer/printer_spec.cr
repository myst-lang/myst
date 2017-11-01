require "./helper.cr"

describe "Printer" do
  it "acts like a visitor" do
    printer = Myst::Printer.new
    printer.responds_to?(:visit).should be_true
  end

  it "has configurable IO" do
    output1 = IO::Memory.new
    output2 = IO::Memory.new
    printer = Myst::Printer.new(output: output1)
    printer.print(parse_program(%q(1)))

    printer.output = output2
    printer.print(parse_program(%q(2)))

    output1.to_s.should eq("1")
    output2.to_s.should eq("2")
  end
end
