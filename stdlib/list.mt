deftype List
  include Enumerable

  # Creates a string representation of this List by calling `join` with the
  # delimiter set as `,`. The result will be wrapped in square brackets.
  #
  # For example: `[1,2,3].to_s` will yield `[1,2,3]`.
  def to_s
    "[" + join(",") + "]"
  end

  # empty? -> bool
  #
  # Return `true` if the List contains 0 characters. Return `false` otherwise.
  def empty?
    size == 0
  end
end
