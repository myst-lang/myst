require "../../spec_helper.cr"
require "../../support/interpret.cr"


describe "NativeLib - Symbol Methods" do
  describe "#to_s" do
    it_interprets %q(:hello.to_s),            [val("hello")]
    it_interprets %q(:"with spaces".to_s),    [val("with spaces")]
    it_interprets %q(:"with\nnewlines".to_s), [val("with\nnewlines")]
  end
end
