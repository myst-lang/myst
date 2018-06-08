require "stdlib/spec.mt"


describe("Map#[]") do
  it("returns the element at the given index") do
    map = {a: 1, b: 2}
    assert(map[:a]).equals(1)
  end

  it("works on map literals") do
    assert({a: 1, b: 2}[:a]).equals(1)
  end

  it("works with nested maps") do
    assert({a: {a1: 1}}[:a][:a1]).equals(1)
  end

  it("returns nil for a non-existent element") do
    assert({a: 1, b: 2}[:c]).is_nil
  end

  describe("with a non-symbol index") do
    it("returns the element at the given index") do
      map = {<1>: :one, <2>: :two}
      assert(map[1]).equals(:one)
    end

    it("works on map literals") do
      assert({<1>: :one, <2>: :two}[2]).equals(:two)
    end

    it("works with nested maps") do
      assert({<"map">: {a: 1}}["map"][:a]).equals(1)
    end

    it("returns nil for a non-existent element") do
      assert({a: 1, b: 2}[false]).is_nil
    end

    it("does not treat negative indices specially") do
      map = {
        <-1>: -1,
        <0>: 0
      }
      assert(map[-1]).equals(-1)
      assert(map[-2]).is_nil
    end
  end
end


describe("Map#[]=") do
  it("assigns to the element at the given index") do
    map = {a: 1, b: 2}
    map[:a] = 2

    assert(map[:a]).equals(2)
    assert(map).equals({a: 2, b: 2})
  end

  it("can assign new elements in the list") do
    map = {}
    map[:a] = 1
    map[:b] = 2

    assert(map).equals({a: 1, b: 2})
  end

  describe("with a non-symbol index") do
    it("assigns to the element at the given index") do
      map = {a: 1, b: 2}
      map[false] = 3

      assert(map[false]).equals(3)
      assert(map).equals({a: 1, b: 2, <false>: 3})
    end

    it("can assign new elements in the list") do
      map = {}
      map["a"] = 1
      map[4.5] = 2

      assert(map).equals({<"a">: 1, <4.5>: 2})
    end
  end
end


describe("Map#==") do
  it("returns true when the maps are equal") do
    assert([1, 2] == [1, 2]).is_true
  end

  it("returns true when the maps are empty") do
    assert({} == {}).is_true
  end

  it("returns false when the lists are different lengths") do
    assert({a: 1, b: 2} == {a: 1}).is_false
  end

  it("returns false when the lists are not equal") do
    assert({a: 1, b: 2} == {a: 1, b: "hi"}).is_false
  end

  it("does not care about the order of entries") do
    assert({a: 1, b: 2} == {b: 2, a: 1}).is_true
  end

  it("returns false when the maps have the same keys but different values") do
    assert({a: 1, b: 2} == {a: 2, b: 1}).is_false
  end
end


describe("Map#!=") do
  it("returns false when the maps are equal") do
    assert([1, 2] != [1, 2]).is_false
  end

  it("returns false when the maps are empty") do
    assert({} != {}).is_false
  end

  it("returns true when the lists are different lengths") do
    assert({a: 1, b: 2} != {a: 1}).is_true
  end

  it("returns true when the lists are not equal") do
    assert({a: 1, b: 2} != {a: 1, b: "hi"}).is_true
  end

  it("does not care about the order of entries") do
    assert({a: 1, b: 2} != {b: 2, a: 1}).is_false
  end

  it("returns true when the maps have the same keys but different values") do
    assert({a: 1, b: 2} != {a: 2, b: 1}).is_true
  end
end


describe("Map#+") do
  it("returns a new Map with the combined elements of both") do
    assert({a: 1} + {b: 2}).equals({a: 1, b: 2})
  end

  it("does not modify the receiving Map") do
    map = {a: 1}
    map2 = map + {b: 2}
    assert(map).equals({a: 1})
  end
end



describe("Map#<") do
  it("returns true if a map is a proper subset of the other") do
    assert({ one: "value_one", two: "value_two"} < { one: "one", two: "two", three: "three"}).is_true
  end

  it("returns true if a map is a proper subset of the other, unsorted") do
   assert({ one: "value_one", two: "value_two" } < { two: "two", three: "three", one: "one" }).is_true
  end

  it("returns false if the maps are the same") do
    assert({ one: "value_one", two: "value_two" } < { one: "one", two: "two" }).is_false
  end

  it("returns false if the map is not a proper subset of the other") do
    assert({ one: "value_one", two: "value_two" } < { one: "one" }).is_false
  end
end


describe("Map#<=") do
  it("returns true if a map is a subset of the other") do
    assert({ one: "value_one", two: "value_two"} <= { one: "one", two: "two", three: "three"}).is_true
  end

  it("returns true if a map is a subset of the other, unsorted") do
   assert({ one: "value_one", two: "value_two" } <= { two: "two", three: "three", one: "one" }).is_true
  end

  it("returns true if the maps are the same") do
    assert({ one: "value_one", two: "value_two" } <= { one: "one", two: "two" }).is_true
  end

  it("returns true if the maps are the same, unsorted") do
    assert({ one: "value_one", two: "v_two" } <= { two: "two", one: "one" }).is_true
  end

  it("returns false if the map is not a subset of the other") do
    assert({ one: "value_one", two: "value_two" } <= { one: "value_one" }).is_false
  end
end


describe("Map#size") do
  it("should return 0 when size is 0") do
    assert({}.size).equals(0)
  end

   it("should return 2 when size is 2") do
    assert({key: 1, b: "hello"}.size).equals(2)
  end
end


describe("Map#empty?") do
  it("should return true when map size is 0") do
    assert({}.empty?).is_true
  end

  it("should return false when map size is 2") do
    assert({key: 1, b: "hello"}.empty?).is_false
  end
end

describe("Map#keys") do
  it("returns a list of the maps keys") do
    assert({foo: :a, bar: :b}.keys) == [:foo, :bar]
  end

  it("returns an empty list when the map is empty") do
    assert({}.keys) == []
  end
end

describe("Map#values") do
  it("returns a list of the maps values") do
    assert({foo: :a, bar: :b}.values) == [:a, :b]
  end

  it("returns an empty list when the map is empty") do
    assert({}.values) == []
  end
end
