require "stdlib/spec.mt"


# TODO: Uncomment once `Map#==` gets implemented (see #113)
#describe("Map#+") do
#  it("returns a new Map with the combined elements of both") do
#    assert({a: 1} + {b: 2} == {a: 1, b: 2})
#  end
#
#  it("does not modify the receiving Map") do
#    map = {a: 1}
#    map2 = map + {b: 2}
#  end
#end


describe("Map#<") do
  it("returns true if a map is a proper subset of the other") do
    assert({ one: "value_one", two: "value_two"} < { one: "one", two: "two", three: "three"})
  end

  it("returns true if a map is a proper subset of the other, unsorted") do
   assert({ one: "value_one", two: "value_two" } < { two: "two", three: "three", one: "one" })
  end

  it("returns false if the maps are the same") do
    refute({ one: "value_one", two: "value_two" } < { one: "one", two: "two" })
  end

  it("returns false if the map is not a proper subset of the other") do
    refute({ one: "value_one", two: "value_two" } < { one: "one" })
  end
end


describe("Map#<=") do
  it("returns true if a map is a subset of the other") do
    assert({ one: "value_one", two: "value_two"} <= { one: "one", two: "two", three: "three"})
  end

  it("returns true if a map is a subset of the other, unsorted") do
   assert({ one: "value_one", two: "value_two" } <= { two: "two", three: "three", one: "one" })
  end

  it("returns true if the maps are the same") do
    assert({ one: "value_one", two: "value_two" } <= { one: "one", two: "two" })
  end

  it("returns true if the maps are the same, unsorted") do
    assert({ one: "value_one", two: "v_two" } <= { two: "two", one: "one" })
  end

  it("returns false if the map is not a subset of the other") do
    refute({ one: "value_one", two: "value_two" } <= { one: "value_one" })
  end
end


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
    assert({}.empty?)
  end

  it("should return false when map size is 2") do
    refute({key: 1, b: "hello"}.empty?)
  end
end
