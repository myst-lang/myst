require "./helper.cr"

describe "Printer" do
  it "acts like a visitor" do
    printer = Myst::Printer.new
    printer.responds_to?(:visit).should be_true
  end
end
