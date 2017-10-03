require "../../spec_helper.cr"
require "../../support/interpret.cr"


describe "NativeLib - Nil Methods" do
  describe "#to_s" do
    it_interprets %q(nil.to_s), [val("nil")]
  end

  describe "#==" do
    it_interprets %q(nil  == nil),      [val(true)]

    # Nil is not equal to any other value
    it_interprets %q(nil  == true),     [val(false)]
    it_interprets %q(nil  == false),    [val(false)]
    it_interprets %q(nil  == 0),        [val(false)]
    it_interprets %q(nil  == 1),        [val(false)]
    it_interprets %q(nil  == 0.0),      [val(false)]
    it_interprets %q(nil  == 1.0),      [val(false)]
    it_interprets %q(nil  == "hello"),  [val(false)]
    it_interprets %q(nil  == :hi),      [val(false)]
    it_interprets %q(nil  == []),       [val(false)]
    it_interprets %q(nil  == [1, 2]),   [val(false)]
    it_interprets %q(nil  == {}),       [val(false)]
    it_interprets %q(nil  == {a: 1}),   [val(false)]
  end

  describe "#!=" do
    it_interprets %q(nil  != nil),      [val(false)]

    # Nil is not equal to any other value
    it_interprets %q(nil  != true),     [val(true)]
    it_interprets %q(nil  != false),    [val(true)]
    it_interprets %q(nil  != 0),        [val(true)]
    it_interprets %q(nil  != 1),        [val(true)]
    it_interprets %q(nil  != 0.0),      [val(true)]
    it_interprets %q(nil  != 1.0),      [val(true)]
    it_interprets %q(nil  != "hello"),  [val(true)]
    it_interprets %q(nil  != :hi),      [val(true)]
    it_interprets %q(nil  != []),       [val(true)]
    it_interprets %q(nil  != [1, 2]),   [val(true)]
    it_interprets %q(nil  != {}),       [val(true)]
    it_interprets %q(nil  != {a: 1}),   [val(true)]
  end
end
