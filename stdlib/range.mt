#doc Range
#| The `Range` type represents the interval between two values. By default,
#| Ranges are _inclusive_, meaning both the first and last values are included
#| as part of the Range.
#|
#| The only values stored by a Range are the lower and upper bounds. The values
#| within the interval are calculated lazily, and only when necessary. With the
#| exceptions of `#each` and `#reverse_each`, most methods are implemented using
#| only comparisons between these bounds.
#|
#| As Myst does not currently provide a literal syntax for Ranges, creating a
#| new Range is done with normal type instantiation, providing the first and
#| last values of the interval as arguments: `%Range{10, 20}`.
#|
#| Any value type can be used in a Range so long as it implements the `<` and
#| `<=` comparison operators. However, to enable iterating through the Range,
#| value types must also implement a `#successor` that returns the next element
#| of the interval.
#|
#| Ranges can also be used in reverse (e.g.,  with `#reverse_each`) if the
#| value type defines a `#predecessor` method returning the previous element
#| of the interval.
#|
#| `Range` includes `Enumerable`, so all of Enumerable's methods can be used
#| directly on Ranges. Where possible, Range provides optimized implementations
#| of Enumerable methods to avoid having to iterate all values in the interval
#| (e.g., `#includes?`).
deftype Range
  # Range defines `#each`, so any type that satisfies the conditions of Range
  # can also be used as an Enumerable.
  include Enumerable

  #doc initialize
  #| Creates a new range for the interval `[first, last]`.
  def initialize(@first, @last); end

  #doc first -> element
  #| Returns the first element of this Range; the lower bound.
  def first; @first; end
  #doc last -> element
  #| Returns the last element of this Range; the upper bound.
  def last; @last; end


  #doc each(&block) -> self
  #| Iterates forward through the Range (starting at `first` and incrementing
  #| to `last`), calling the block for every element in the interval.
  def each(&block) : Range
    current = @first
    while current <= @last
      block(current)
      current = current.successor
    end

    self
  end

  #doc reverse_each(&block) -> self
  #| Iterates backward through the Range (starting at `last` and decrementing
  #| to `first`), calling the block for every element in the interval.
  def reverse_each(&block) : Range
    current = @last
    while @first <= current
      block(current)
      current = current.predecessor
    end

    self
  end


  #doc includes?(value) -> boolean
  #| Returns true if `value` exists within the interval of this Range.
  #|
  #| This method has an `O(1)` implementation using only comparisons with the
  #| bounds of the interval.
  def includes?(value) : Boolean
    !!(@first <= value && value <= @last)
  end


  #doc to_s -> string
  #| Returns an abstract string representation of the interval covered by this
  #| Range. Note that this does _not_ return a string of all the values in the
  #| interval.
  def to_s : String
    "(<(@first)>..<(@last)>)"
  end
end
