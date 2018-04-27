require "stdlib/spec.mt"


describe("Range") do
  range = %Range{0, 10}

  describe("#first") do
    it("returns the lower bound of the Range") do
      assert(range.first).equals(0)
    end
  end

  describe("#last") do
    it("returns the upper bound of the Range") do
      assert(range.last).equals(10)
    end
  end


  describe("#each") do
    it("calls the block for every element in the Range's interval") do
      range = %Range{5, 10}
      counter = 0
      range.each{ |_| counter += 1 }
      # This is 6 instead of 5 because the last element is included as part of
      # the range. 5, 6, 7, 8, 9, 10.
      assert(counter).equals(6)
    end

    it("iterates forward through the interval, in order") do
      range = %Range{5, 10}
      list = []
      range.each{ |e| list.push(e) }

      assert(list).equals([5, 6, 7, 8, 9, 10])
    end
  end

  describe("#reverse_each") do
    it("calls the block for every element in the Range's interval") do
      range = %Range{5, 10}
      counter = 0
      range.reverse_each{ |_| counter += 1 }
      # This is 6 instead of 5 because the last element is included as part of
      # the range. 5, 6, 7, 8, 9, 10.
      assert(counter).equals(6)
    end

    it("iterates backward through the interval, in order") do
      range = %Range{5, 10}
      list = []
      range.reverse_each{ |e| list.push(e) }

      assert(list).equals([10, 9, 8, 7, 6, 5])
    end
  end


  describe("#includes?") do
    range = %Range{0, 10}

    it("returns true when the value is within the Range's interval") do
      assert(range.includes?(5)).is_true
    end

    it("returns false when the value is above the Range's interval") do
      assert(range.includes?(11)).is_false
    end

    it("returns false when the value is below the Range's interval") do
      assert(range.includes?(-1)).is_false
    end

    it("returns true when the value is the Range's lower bound") do
      assert(range.includes?(0)).is_true
    end

    it("returns true when the value is the Range's upper bound") do
      assert(range.includes?(10)).is_true
    end
  end


  describe("#to_s") do
    it("returns a string representing the bounds of the interval") do
      range = %Range{0, 10}
      assert(range.to_s).equals("(0..10)")
    end
  end
end
