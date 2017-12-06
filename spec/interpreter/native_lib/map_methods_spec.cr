require "../../spec_helper.cr"
require "../../support/interpret.cr"

describe "NativeLib - Map Methods" do
  describe "#+" do
    it_interprets %q({ a: "b"} + { c: "d" }), [val({:a => "b", :c => "d"})]
    it_interprets %q({ a: "b"} + { a: "b2" }), [val({:a => "b2"})]    
  end
end
