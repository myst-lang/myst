# This file is for documentation purposes only. The methods defined here
# are implemented as part of the native library of Myst. They are reproduced
# here to allow the documentation generator to include native documentation.

#doc List
#| A List is a dynamically-sized, ordered collection of values.
deftype List
  #doc each -> self
  #| Iterate the elements of this List. On each iteration, call `block` with
  #| that element of the list as the argument.
  #|
  #| Returns the original, unmodified List after completion.
  def each(&block) : List; end

  #doc size -> integer
  #| Returns the number of elements contained in this List as an integer.
  def size : Integer; end

  #doc * -> self
  #| The splat operation. For Lists, this is a no-op and simply returns the
  #| List itself.
  def * : List; end

  #doc == -> boolean
  #| Returns `true` if `other` is also a List, has the same number of elements,
  #| and the elements at every index of `other` are equal to those in this
  #| List.
  #|
  #| If `other` is not a List, or if any of those conditions are not met, this
  #| method will return `false`.
  def ==(other) : Boolean; end

  #doc != -> boolean
  #| Returns `false` only if `other` is also a List, has the same number of
  #| elements, and the elements at every index of `other` are equal to those in
  #| this List.
  #|
  #| If `other` is not a List, or if any of those conditions are not met, this
  #| method will return `true`.
  def !=(other) : Boolean; end

  #doc + -> list
  #| Returns a new List object with the elements of `other` appended to the end
  #| of this list.
  def +(other : List) : List; end

  #doc [] -> value?
  #| Returns the element of the list at position `index`. If this list does not
  #| have an element at `index`, this method will return `nil`.
  def [](index : Integer); end

  #doc []= -> value
  #| Sets the element of this list at position `index` to `value`. If the list
  #| previously contained fewer than `index` elements, it will grow to that
  #| size, filling the new indices with `nil`.
  #|
  #| This method returns `value` to be usable in chained expressions.
  def []=(index : Integer, value); end

  #doc - -> list
  #| Returns a new List object with the elements of `other` removed from this list.
  def -(other : List) : List; end

  #doc < -> boolean
  #| Returns `true` if this list is a proper subset of `other`. That is, if
  #| every element of this list is also present in `other`, _and_ `other` also
  #| contains at least one other element.
  #|
  #| The order of elements in the lists is not important for this method.
  def <(other : List) : Boolean; end

  #doc <= -> boolean
  #| Returns `true` if this list is a subset of `other`. That is, if every
  #| element of this list is also present in `other`. `other` does _not_ have
  #| to contain any other elements.
  #|
  #| The order of elements in the lists is not important for this method.
  def <=(other : List) : Boolean; end

  #doc push(*args) -> self
  #| Adds the given elements to the end of this list as individual entries.
  #|
  #| Returns the same list object with the new elements added.
  def push(*args) : List; end

  #doc pop -> value?
  #| Attempts to remove the last element from this list and return it. If the
  #| list does not currently contain any elements to remove, this method will
  #| return `nil` instead.
  def pop; end

  #doc unshift(*args) -> self
  #| Similar to `push`, but appends the elements to the front of the list
  #| instead of to the end.
  #|
  #| Returns the same list object with the new elements added at the beginning
  #| of the list.
  #|
  #| Note that with multiple arguments, this method preserves their ordering.
  #| For example: `[1, 2].unshift(3, 4)` will result in the list `[3, 4, 1, 2]`.
  def unshift(*args) : List; end

  #doc shift -> value?
  #| Similar to `pop`, but attempts to remove and return the first element of
  #| the list instead of the last element. If the list does not currently
  #| contain any elements to remove, this method will return `nil` instead.
  def shift; end
end
