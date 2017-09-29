require "../../spec_helper.cr"
require "../../support/interpret.cr"


describe "NativeLib - List Methods" do
  describe "#each" do
    # `each` should return the original list without modifications
    it_interprets %q([1, 2].each{ |e|  }), [val([1, 2])]
    it_interprets %q(
      [1, 2].each do |e|
        (e * 2).to_s
      end
    ),                    [val([1, 2])]

    it_interprets %q(
      [1, "hi", 5.4].each do |e|
        (e * 2).to_s
      end
    ),                    [val([1, "hi", 5.4])]
  end
end
