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

describe("Enumerable#min") do
  it("returns the minimum element from a list") do
    assert([3, 1, 2].min == 1)
  end

  it("returns single element") do
    assert([1].min == 1)
  end

  it("returns nil if the list is empty") do
    assert([].min == nil)
  end
end

describe("Enumerable#max") do
  it("returns the maximum element from a list") do
    assert([1, 3, 2].max == 3)
  end

  it("returns single element") do
    assert([1].max == 1)
  end

  it("returns nil if the list is empty") do
    assert([].max == nil)
  end
end

describe("Enumerable#any?") do
  it("returns true if at least one element evaluates to true for the given block") do
    assert([1, 2, 3].any? { |number| number > 2 })
  end

  it("returns false if no elements evaluate to true for the given block") do
    refute([1, 2, 3].any? { |number| number > 5 })
  end
end

describe("Enumerable#sort") do
  it("sorts") do
    assert([1, 3, 4, 2, 7, 5, 6].sort == [1, 2, 3, 4, 5, 6, 7])
  end

  it("single element") do
    assert([1].sort == [1])
  end
end

deftype Fake
  include Enumerable

  def each(&block)
    i = 0
    
    while i < 3
      block(i)
      i += 1
    end 

    nil
  end
end

describe("Enumerable#to_list") do
  it("converts to a list") do
    assert(%Fake{}.to_list == [0, 1, 2])
  end
end
