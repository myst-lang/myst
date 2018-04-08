deftype List
  include Enumerable

  #doc to_s -> string
  #| Creates a string representation of this List by calling `join` with the
  #| delimiter set as `,`. The result will be wrapped in square brackets.
  #|
  #| For example: `[1,2,3].to_s` will yield `[1,2,3]`.
  def to_s
    "[" + join(",") + "]"
  end

  def first
    self[0]
  end

  def first?
    first
  rescue
    nil
  end

  def last
    self[self.size - 1]
  end

  def last?
    last
  rescue
    nil
  end

  #doc empty? -> bool
  #| Return `true` if the List contains 0 elements. Return `false` otherwise.
  def empty?
    size == 0
  end
end
