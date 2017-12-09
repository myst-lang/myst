require "stdlib/spec.mt"

describe("Enumerable#size") do
  it("returns the right size") do
    assert([1, 2, 3].size == 3)
  end
end

describe("Enumerable#all?") do
  it("returns true if the the given block evaluates to true for all elements") do
    assert([1, 2, 3].all?{ |el| true })
  end

  it("returns false if the given block returns false for any element") do
    result = [true, false, false].all?{ |el| el }
    assert(result == false)
  end
end

describe("Enumerable#find") do
  it("returns 1 if there is a 1") do
    assert([1, 2, 3].find{ |el| el == 1 } == 1)
  end

  it("returns nil if no matching element is found") do
    assert([1, 2, 3].find{ |el| el == 0 } == nil)
  end
end
