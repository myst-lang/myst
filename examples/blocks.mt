# Blocks are implicit functors defined either by a `do...end` or `{}` code
# segment following a function call. Unlike in Ruby, blocks are always just
# normal, un-named functors. No wrapping or unwrapping occurs at any point,
# other than potentially assigning to a local variable when a block is
# explicitly captured by a function.

# First, look at how blocks are sent by the caller. The following splits the
# initial String into a List of Strings - `["hello", "world"]`. `.each()` then
# iterates each element of the List and calls the block provided by the
# `do..end` section that follows it for each element of the List.
#
# The result of running this example should be:
#   hello
#   world
"hello world".split().each() do |word|
  IO.puts(word)
end

# Blocks can also take multiple arguments. A simple example is when iterating
# a Map, where the provided block takes two arguments, the key and the value.
{a: 1, b: "hello", c: 4}.each() do |key, value|
  IO.puts(key)
  IO.puts(value)
end


# Blocks also close over local variables (their scope is that in which the
# block is defined), this allows functions do define behavior that can operate
# on outside values.
x = 0
[0, 1, 2, 3].each() do |elem|
  x = x + 1
end
IO.puts(x) #=> 4


# Defining a method that takes a block is currently only supported implicitly.
# That is, the block argument cannot be specified in the function head and can
# only be called using `yield`.
def pairs(element1, element2, element3)
  # `yield` acts exactly like any other function call, and all parameter syntax
  # rules can be used.
  yield(element1, element2)
  yield(element1, element3)
  yield(element2, element3)
end

pairs(1, 2, 3) do |elem1, elem2|
  IO.puts("Pair: " + elem1.to_s() + ", " + elem2.to_s())
end
