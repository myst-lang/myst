require "../../spec_helper.cr"
require "../../support/interpret.cr"


describe "NativeLib - Boolean Methods" do
  describe "#to_s" do
    it_interprets %q(false.to_s), [val("false")]
    it_interprets %q(true.to_s), [val("true")]

    it_interprets %q((true && true).to_s),    [val("true")]
    it_interprets %q((false || false).to_s),  [val("false")]
  end

  describe "#==" do
    # Standard boolean truthtable
    it_interprets %q(false  == false),  [val(true)]
    it_interprets %q(false  == true),   [val(false)]
    it_interprets %q(true   == false),  [val(false)]
    it_interprets %q(true   == true),   [val(true)]

    # Using #==, the argument must be a boolean with the same value. #== is
    # _not_ a check for truthiness.
    it_interprets %q(true   == nil),      [val(false)]
    it_interprets %q(true   == 0),        [val(false)]
    it_interprets %q(true   == 1),        [val(false)]
    it_interprets %q(true   == 1.0),      [val(false)]
    it_interprets %q(true   == "hello"),  [val(false)]
    it_interprets %q(true   == :hi),      [val(false)]
    it_interprets %q(true   == []),       [val(false)]
    it_interprets %q(true   == [1, 2]),   [val(false)]
    it_interprets %q(true   == {}),       [val(false)]
    it_interprets %q(true   == {a: 1}),   [val(false)]

    it_interprets %q(false  == nil),      [val(false)]
    it_interprets %q(false  == 0),        [val(false)]
    it_interprets %q(false  == 1),        [val(false)]
    it_interprets %q(false  == 1.0),      [val(false)]
    it_interprets %q(false  == "hello"),  [val(false)]
    it_interprets %q(false  == :hi),      [val(false)]
    it_interprets %q(false  == []),       [val(false)]
    it_interprets %q(false  == [1, 2]),   [val(false)]
    it_interprets %q(false  == {}),       [val(false)]
    it_interprets %q(false  == {a: 1}),   [val(false)]

    # Since #== always returns a boolean, it can be chained to do an equality
    # comparison, followed by an assertion on true/false.
    it_interprets %q(false  == false  == false),  [val(false)]
    it_interprets %q(false  == true   == false),  [val(true)]
    it_interprets %q(false  == false  == true),   [val(true)]
    it_interprets %q(false  == true   == true),   [val(false)]
    it_interprets %q(true   == false  == false),  [val(true)]
    it_interprets %q(true   == true   == false),  [val(false)]
    it_interprets %q(true   == false  == true),   [val(false)]
    it_interprets %q(true   == true   == true),   [val(true)]
  end

  # Boolean#!= is the exact inverse of Boolean#==.
  describe "#!=" do
    it_interprets %q(false  != false),  [val(false)]
    it_interprets %q(false  != true),   [val(true)]
    it_interprets %q(true   != false),  [val(true)]
    it_interprets %q(true   != true),   [val(false)]

    it_interprets %q(true   != nil),      [val(true)]
    it_interprets %q(true   != 0),        [val(true)]
    it_interprets %q(true   != 1),        [val(true)]
    it_interprets %q(true   != 1.0),      [val(true)]
    it_interprets %q(true   != "hello"),  [val(true)]
    it_interprets %q(true   != :hi),      [val(true)]
    it_interprets %q(true   != []),       [val(true)]
    it_interprets %q(true   != [1, 2]),   [val(true)]
    it_interprets %q(true   != {}),       [val(true)]
    it_interprets %q(true   != {a: 1}),   [val(true)]

    it_interprets %q(false  != nil),      [val(true)]
    it_interprets %q(false  != 0),        [val(true)]
    it_interprets %q(false  != 1),        [val(true)]
    it_interprets %q(false  != 1.0),      [val(true)]
    it_interprets %q(false  != "hello"),  [val(true)]
    it_interprets %q(false  != :hi),      [val(true)]
    it_interprets %q(false  != []),       [val(true)]
    it_interprets %q(false  != [1, 2]),   [val(true)]
    it_interprets %q(false  != {}),       [val(true)]
    it_interprets %q(false  != {a: 1}),   [val(true)]


    it_interprets %q(false  != false  != false),  [val(false)]
    it_interprets %q(false  != true   != false),  [val(true)]
    it_interprets %q(false  != false  != true),   [val(true)]
    it_interprets %q(false  != true   != true),   [val(false)]
    it_interprets %q(true   != false  != false),  [val(true)]
    it_interprets %q(true   != true   != false),  [val(false)]
    it_interprets %q(true   != false  != true),   [val(false)]
    it_interprets %q(true   != true   != true),   [val(true)]
  end
end
