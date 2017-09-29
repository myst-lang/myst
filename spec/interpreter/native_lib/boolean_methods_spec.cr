require "../../spec_helper.cr"
require "../../support/interpret.cr"


describe "NativeLib - Boolean Methods" do
  describe "#to_s" do
    it_interprets %q(false.to_s), [val("false")]
    it_interprets %q(true.to_s), [val("true")]

    it_interprets %q((true && true).to_s),    [val("true")]
    it_interprets %q((false || false).to_s),  [val("false")]
  end
end
