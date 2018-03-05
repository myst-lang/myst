require "stdlib/spec.mt"


describe("List#* (splat)") do
  it("should return itself") do
    assert{ *[1, 2, 3] }.returns([1, 2, 3])
  end

  it("spreads elements into list literals (flattening)") do
    assert{ [*[1, 2], *[3, 4]] }.returns([1, 2, 3, 4])
  end

  it("does not flatten nested lists") do
    assert{ *[[1, 2], [3, 4]] }.returns([[1, 2], [3, 4]])
  end
end


describe("List#==") do
  it("returns true when the lists are equal") do
    assert([1, 2] == [1, 2]).is_true
  end

  it("returns true when the lists are empty") do
    assert([] == []).is_true
  end

  it("returns false when the lists are different lengths") do
    assert([1] == [1, 2]).is_false
  end

  it("returns false when the lists are not equal") do
    assert([1, 2] == [1, "hi"]).is_false
  end

  it("returns false when the same elements are in different orders") do
    assert([1, 2, 3] == [1, 3, 2]).is_false
  end
end

describe("List#!=") do
  it("returns false when the lists are equal") do
    assert([1, 2] != [1, 2]).is_false
  end

  it("returns false when the lists are empty") do
    assert([] != []).is_false
  end

  it("returns true when the lists are different lengths") do
    assert([1] != [1, 2]).is_true
  end

  it("returns true when the lists are not equal") do
    assert([1, 2] != [1, "hi"]).is_true
  end

  it("returns true when the same elements are in different orders") do
    assert([1, 2, 3] != [1, 3, 2]).is_true
  end
end


describe("List#-") do
  it("returns elements not present in second list") do
    assert(([1, 2] - [1])).equals([2])
  end

  it("returns the first list if there are no present elements in the second list") do
    assert(([1, 2] - [3])).equals([1, 2])
  end

  it("returns any empty list if the lists are equal") do
    assert(([1, 2] - [1, 2])).equals([])
  end
end


describe("List#<") do
  it("returns true if a list is a proper subset of the other") do
    assert([1, "hi"] < [1, "hi", 3]).is_true
  end

  it("returns true if a list is a proper subset of the other, unsorted") do
    assert([3, 1] < [1, 2, 3]).is_true
  end

  it("returns false if the lists are the same") do
    assert([1, 2] < [1, 2]).is_false
  end

  it("returns false if the list is not a proper subset of the other") do
    assert([1, 2] < [1]).is_false
  end
end


describe("List#<=") do
  it("returns true if a list is a subset of the other") do
    assert([1, "hi"] <= [1, "hi", 3]).is_true
  end

  it("returns true if a list is a subset of the other, unsorted") do
    assert([3, 1] < [1, 2, 3]).is_true
  end

  it("returns true if the lists contain the same elemtns") do
    assert([1, 2] <= [1, 2]).is_true
  end

  it("returns true if the lists contain the same elements, unsorted") do
    assert([3, 1, 2] <= [1, 2, 3]).is_true
  end

  it("returns false if the list is not a subset of the other") do
    assert([1, 2] <= [1]).is_false
  end
end


describe("List#[]") do
  it("returns the element at the given index") do
    list = [1, 2]
    assert(list[0]).equals(1)
  end

  it("works on list literals") do
    assert([1, 2][0]).equals(1)
  end

  it("works with nested lists") do
    assert([[1, 2], [3, 4]][1][0]).equals(3)
  end

  it("returns nil for an out-of-bounds access") do
    assert([1, 2][3]).is_nil
  end

  describe("with a negative index") do
    it("is 1-based, counting from the end") do
      assert([1, 2][-1]).equals(2)
    end

    it("returns the nth element from the end of the list") do
      assert([1, 2, 3][-2]).equals(2)
    end

    it("returns nil for out-of-bounds access") do
      assert([1, 2][-3]).is_nil
    end
  end
end


describe("List#[]=") do
  it("assigns to the element at the given index") do
    list = [1, 2]
    list[0] = 2

    assert(list).equals([2, 2])
  end

  it("can assign new elements in the list") do
    list = []
    list[0] = 1
    list[1] = 2

    assert(list).equals([1, 2])
  end

  it("fills skipped elements with nil") do
    list = []
    list[3] = 1

    assert(list).equals([nil, nil, nil, 1])
  end

  describe("with a negative index") do
    it("is 1-based, counting from the end") do
      list = [1, 2]
      list[-1] = 3
      assert(list).equals([1, 3])
    end

    it("assigns the nth element from the end of the list") do
      list = [1, 2, 3]
      list[-2] = 0
      assert(list).equals([1, 0, 3])
    end
  end
end


describe("List#each") do
  it("calls the block once for each element") do
    call_count = 0
    [1, 2, 3].each do |e|
      call_count += 1
    end

    assert(call_count).equals(3)
  end

  it("returns the original list with no modifications") do
    original_list = [1, 2, 3]
    returned_list = original_list.each{ |e| }

    assert(original_list).equals(returned_list)
  end

  it("passes elements by reference to the block") do
    deftype T
      def called; @called; end
      def called=(new); @called = new; end
    end

    list = [%T{}, %T{}]
    list.each do |t|
      t.called = true
    end

    assert(list[0].called).is_true
    assert(list[1].called).is_true
  end
end


describe("List#size") do
  it("should return 0 when size is 0") do
    assert([].size).equals(0)
  end

  it("should return 3 when size is 3") do
    assert([1,2,3].size).equals(3)
  end
end


describe("List#empty?") do
  it("should return true when list size is 0") do
    assert([].empty?).is_true
  end

  it("should return false when list size is 2") do
    assert([1, 2].empty?).is_false
  end
end

describe("List#push") do
  it("add elements to the list") do
    assert([1,2].push(3)).equals([1, 2, 3])
    assert([1,2].push("hi")).equals([1, 2, "hi"])
    assert([1,2].push(nil)).equals([1, 2, nil])
    assert([1,2].push(*[3,4])).equals([1, 2, 3, 4])
    assert([1,2].push([3,4])).equals([1, 2, [3, 4]])
  end

  it("returns list if no value provided") do
    assert([1,2].push).equals([1, 2])
  end
end

describe("List#pop") do
  it("returns last element from the list") do
    assert([1,2,3].pop).equals(3)
  end

  it("removes last element from the list") do
    l = [1,2]
    l.pop
    assert(l).equals([1])
  end

  it("returns nil if no element to pop") do
    assert([].pop).is_nil
  end
end

describe("List#unshift") do
  it("add elements to front of the list") do
    assert([1,2].unshift(3)).equals([3, 1, 2])
    assert([1,2].unshift("hi")).equals(["hi", 1, 2])
    assert([1,2].unshift(nil)).equals([nil, 1, 2])
    assert([1,2].unshift(*[3,4])).equals([3, 4, 1, 2])
    assert([1,2].unshift([3,4])).equals([[3, 4], 1, 2])
  end

  it("returns nil if no value provided") do
    assert([1,2].unshift).equals([1, 2])
  end
end

describe("List#shift") do
  it("returns first element from the list") do
    assert([1,2,3].shift).equals(1)
  end

  it("removes first element from the list") do
    l = [1,2]
    l.shift
    assert(l).equals([2])
  end

  it("returns nil if no element to unshift") do
    assert([].shift).is_nil
  end
end
