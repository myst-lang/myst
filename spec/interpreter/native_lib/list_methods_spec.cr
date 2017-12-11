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

  describe "#[]" do
    it_interprets %q(
      l = [1, 2, 3]
      l[1]
    ), [val(2)]

    it_interprets %q(
      l = []
      l[5]
    ), [val(nil)]
  end

  describe "#[]=" do 
    it_interprets %q(
      l = []
      l[0] = 1
    ), [val(1)]

    it_interprets %q(
      l = []
      l[3] = 1
      l
    ), [val([nil, nil, nil, 1])]

    it_interprets %q(
      l = [1, 2, 3]
      l[2] = 4
    ), [val(4)]

    it_interprets %q(
      l = [1, 2, 3]
      l[2] = 4
      l
    ), [val([1, 2, 4])]
  end
end
