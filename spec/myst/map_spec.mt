require "stdlib/spec.mt"

describe("Map#size") do
  it("should return 0 when size is 0") do
    assert({}.size == 0)
  end

   it("should return 2 when size is 2") do
    assert({key: 1, b: "hello"}.size == 2)
  end
end

describe("Map#empty?") do
  it("should return true when map size is 0") do
    assert({}.empty? == true)
  end

  it("should return false when map size is 2") do
    assert({key: 1, b: "hello"}.empty? == false)
  end
end

describe("Map#<") do
  it("returns true if a map is a subset of the other") do
    assert(({ one: "value_one", two: "value_two"} < { one: "one", two: "two", three: "three"}) == true)
  end

  it("returns true if a map is a subset of the other, unsorted") do
   assert(({ one: "value_one", two: "value_two" } < { two: "two", three: "three", one: "one" }) == true)
  end

  it("returns false if the maps are the same") do
    assert(({ one: "value_one", two: "value_two" } < { one: "one", two: "two" }) == false)
  end

  it("returns false if the map is not a proper subset of the other") do
    assert(({ one: "value_one", two: "value_two" } < { one: "one" }) == false)
  end
end

describe("Map#<=") do
  it("returns true if a map is a subset of the other") do
    assert(({ one: "value_one", two: "value_two"} <= { one: "one", two: "two", three: "three"}) == true)
  end

  it("returns true if a map is a subset of the other, unsorted") do
   assert(({ one: "value_one", two: "value_two" } <= { two: "two", three: "three", one: "one" }) == true)
  end

  it("returns true if the maps are the same") do
    assert(({ one: "value_one", two: "value_two" } <= { one: "one", two: "two" }) == true)
  end

  it("returns true if the maps are the same, unsorted") do
    assert(({ one: "value_one", two: "v_two" } <= { two: "two", one: "one" }) == true)
  end

  it("returns false if the map is not a subset of the other") do
    assert(({ one: "value_one", two: "value_two" } <= { one: "value_one" }) == false)
  end
end
