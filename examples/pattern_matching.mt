# Pattern matching can be used to set simple expectations on values. If a match
# fails for any reason, it will raise a `MatchError`.

# Because of that, the following will raise an error. It says that `x` is equal
# to `1`, and then that `x` is expected to match the value `2`, which it
# clearly does not.
x = 1

# When a match passes, it returns the right-hand-side value, meaning it can be
# used for through-assignment. For simple matches, this is somewhat awkward,
# and should generally be avoided, but is useful for more complex matches seen
# later on.
x = 1
v = 1 =: x
IO.puts(v) #=> 1

# Variables can also be assigned with pattern-matching assignment. Using an
# identifier on the left-hand-side of a match expression will assign the
# right-hand-side's value to it unconditionally. In essence, using one
# identifier on the left-hand-side is (mostly) the same as simple assignment.
list = [1, 2, 3]
x =: list[2]

# Pattern matching also allows for complex destructuring of the right-hand-side
# into the structure defined by the left-hand-side. This is really the primary
# use case for pattern matching.
# In this example, the first element of the two lists is pattern-matched
# successfully (both are the value `1`), then `b` is bound to `"hello"`, and
# `c` is bound to `false`.
[1, b, c] =: [1, "hello", false]
IO.puts(b) #=> "hello"
IO.puts(c) #=> false

# Nested values are also supported in pattern matching.
[1, b, ["nested", c], map] =: [1, 2, ["nested", "lists"], {a: 1, b: 2}]
IO.puts(c) #=> "lists"
IO.puts(map) #=> {a: 1, b: 2}

# Pattern matching is performed left-to-right. Normally, this is not important,
# but combined with variable re-use and value interpolation, this makes pattern
# matchinde extremely powerful when enforcing structures.
[a, <(a*3)>] =: ["hi", "hihihi"]
IO.puts(a) #=> "hi"

# Pattern matching for lists also allows for splat collectors, similar to how
# they are used in function parameters. Only one splat collector is allowed in
# a List pattern.
[head, *tail] =: [1, 2, 3]
IO.puts(tail) #=> [2, 3]
# A splat collector matches successfully when 0 or more elements remain to be
# matched. If there are no elements, the collector will become an empty List.
[a, b, c, *rest] =: [1, 2, 3]
IO.puts(rest) #=> []
# Splat collectors may be used anywhere in the List pattern.
[first, *_, last] =: [1, 2, 3, 4]
IO.puts(first) #=> 1
IO.puts(last) #=> 4



# Unlike Lists, pattern matching for Maps is _not_ exhaustive, nor is it order-
# dependent. That is, as long as the value contains _at least_ the content
# defined in the pattern, the match will succeed. Any extra entries will simply
# be ignored by the match.
map = {a: 1, b: 2, c: 3}
{a: a, b: b} =: map
IO.puts(a) #=> 1
IO.puts(b) #=> 2

# Like Lists, the entries of a Map pattern may be any other valid pattern.
{a: a, b: <(a*2)>, c: <(a*3)>} =: map
IO.puts(a) #=> 1
