require "../../spec_helper.cr"
require "../../support/interpret.cr"


describe "NativeLib - Nil Methods" do
  describe "#to_s" do
    it_interprets %q(nil.to_s), [val("nil")]
  end
end
