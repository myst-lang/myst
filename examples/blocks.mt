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
  STDOUT.puts(word)
end

# Blocks can also take multiple arguments. A simple example is when iterating
# a Map, where the provided block takes two arguments, the key and the value.
{a: 1, b: "hello", c: 5}.each() do |key, value|
  STDOUT.puts(key)
  STDOUT.puts(value)
end


# Blocks also close over local variables (their scope is that in which the
# block is defined), this allows functions do define behavior that can operate
# on outside values.
x = 0
[0, 1, 2, 3].each() do |elem|
  x = x + 1
end
STDOUT.puts(x) #=> 4


# Defining a function that accepts a block is done by adding an extra parameter
# at the end of the function head with an ampersand as a prefix. The block
# parameter can be named with any valid identifier, and will be available in
# the function scope for calling like any normal function.
def pairs(element1, element2, element3, &block)
  block(element1, element2)
  block(element1, element3)
  block(element2, element3)
end

pairs(1, 2, 3) do |elem1, elem2|
  STDOUT.puts("Pair: " + elem1.to_s() + ", " + elem2.to_s())
end
