require "stdlib/spec.mt"


describe("List#* (splat)") do
  it("should return itself") do
    assert(*[1, 2, 3] == [1, 2, 3])
  end

  it("spreads elements into list literals (flattening)") do
    assert([*[1, 2], *[3, 4]] == [1, 2, 3, 4])
  end

  it("does not flatten nested lists") do
    assert(*[[1, 2], [3, 4]] == [[1, 2], [3, 4]])
  end
end


describe("List#==") do
  it("returns true when the lists are equal") do
    assert([1, 2] == [1, 2])
  end

  it("returns true when the lists are empty") do
    assert([] == [])
  end

  it("returns false when the lists are different lengths") do
    refute([1] == [1, 2])
  end

  it("returns false when the lists are not equal") do
    refute([1, 2] == [1, "hi"])
  end
end


describe("List#-") do
  it("returns elements not present in second list") do
    assert(([1, 2] - [1]) == [2])
  end

  it("returns the first list if there are no present elements in the second list") do
    assert(([1, 2] - [3]) == [1, 2])
  end

  it("returns any empty list if the lists are equal") do
    assert(([1, 2] - [1, 2]) == [])
  end
end


describe("List#<") do
  it("returns true if a list is a proper subset of the other") do
    assert([1, "hi"] < [1, "hi", 3])
  end

  it("returns true if a list is a proper subset of the other, unsorted") do
    assert([3, 1] < [1, 2, 3])
  end

  it("returns false if the lists are the same") do
    refute([1, 2] < [1, 2])
  end

  it("returns false if the list is not a proper subset of the other") do
    refute([1, 2] < [1])
  end
end


describe("List#<=") do
  it("returns true if a list is a subset of the other") do
    assert([1, "hi"] <= [1, "hi", 3])
  end

  it("returns true if a list is a subset of the other, unsorted") do
    assert([3, 1] < [1, 2, 3])
  end

  it("returns true if the lists contain the same elemtns") do
    assert([1, 2] <= [1, 2])
  end

  it("returns true if the lists contain the same elements, unsorted") do
    assert([3, 1, 2] <= [1, 2, 3])
  end

  it("returns false if the list is not a subset of the other") do
    refute([1, 2] <= [1])
  end
end


describe("List#[]") do
  it("returns the element at the given index") do
    list = [1, 2]
    assert(list[0] == 1)
  end

  it("works on list literals") do
    assert([1, 2][0] == 1)
  end

  it("works with nested lists") do
    assert([[1, 2], [3, 4]][1][0] == 3)
  end

  it("returns nil for an out-of-bounds access") do
    assert([1, 2][3] == nil)
  end

  describe("with a negative index") do
    it("is 1-based, counting from the end") do
      assert([1, 2][-1] == 2)
    end

    it("returns the nth element from the end of the list") do
      assert([1, 2, 3][-2] == 2)
    end

    it("returns nil for out-of-bounds access") do
      assert([1, 2][-3] == nil)
    end
  end
end


describe("List#[]=") do
  it("assigns to the element at the given index") do
    list = [1, 2]
    list[0] = 2

    assert(list == [2, 2])
  end

  it("can assign new elements in the list") do
    list = []
    list[0] = 1
    list[1] = 2

    assert(list == [1, 2])
  end

  it("fills skipped elements with nil") do
    list = []
    list[3] = 1

    assert(list == [nil, nil, nil, 1])
  end

  describe("with a negative index") do
    it("is 1-based, counting from the end") do
      list = [1, 2]
      list[-1] = 3
      assert(list == [1, 3])
    end

    it("assigns the nth element from the end of the list") do
      list = [1, 2, 3]
      list[-2] = 0
      assert(list == [1, 0, 3])
    end
  end
end


describe("List#each") do
  it("calls the block once for each element") do
    call_count = 0
    [1, 2, 3].each do |e|
      call_count += 1
    end

    assert(call_count = 3)
  end

  it("returns the original list with no modifications") do
    original_list = [1, 2, 3]
    returned_list = original_list.each{ |e| }

    assert(original_list == returned_list)
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

    assert(list[0].called == true)
    assert(list[1].called == true)
  end
end


describe("List#size") do
  it("should return 0 when size is 0") do
    assert([].size == 0)
  end

  it("should return 3 when size is 3") do
    assert([1,2,3].size == 3)
  end
end


describe("List#empty?") do
  it("should return true when list size is 0") do
    assert([].empty? == true)
  end

  it("should return false when list size is 2") do
    assert([1, 2].empty? == false)
  end
end
