# Unlike most languages in the C ancestry, Myst does _not_ have the concept of
# a singular `if` or `else if` construct. Instead, Myst adapts a structure
# similar to Ruby's `case...when` for all conditional statements. The only
# difference from Ruby is that the `case` keyword is dropped.
#
# `when` blocks are a chainable construct for executing code conditionally. A
# single `when` block will evaluate it's condition and execute the following
# block if the condition is truthy, exactly like a normal `if` in most other
# languages.
#
# If a `when` block is directly succeeded by another `when` block (i.e.,
# without an `end` to match the previous `when`), it will only be evaluated if
# the previous `when`'s condition was _not_ truthy. This achieves the same
# effect as the  traditional `if...else if` construct, but with a consistent
# syntax that makes parsing multiple chained conditions easier on the eyes.
when true
  STDOUT.puts("this will always run")
when false
  STDOUT.puts("this will never run")
end

when false
  STDOUT.puts("this will never run")
when true
  STDOUT.puts("this will always run")
end


# `when`s can also be succeeded by a catch-all `else` block, which will always
# execute it's body if none of the preceding `when`s' conditions were met.
# `else` blocks _must_ be the final block in a `when` chain.
when false
  # something
when false
  # somthing else
else
  STDOUT.puts("this will always run")
end


# To more naturally specify the _inverse_ of a condition (that is, to evaluate
# the block when the condition is _false_), `unless` may replace `when`. This
# is valid at any point in a `when` chain.
when false
  STDOUT.puts("this will never run")
unless false
  STDOUT.puts("runs when condition is falsey")
end


# All `when` blocks create a new, temporary, _restrictive_ scope every time
# they are run. This means that any new variables bound via a pattern matching
# condition or inside of the block itself will be freed at the end of the
# block. However, existing variables from the containing scope will still be
# accessible for pattern matching in conditions, and will be assignable in the
# body of the block.
value = 4

when value =: 10
  # `value` is a new variable with the value `10`. The `value` defined
  # previously is not affected, and will retain its value of `4`.
when <(value*2)> =: 8
  # Here, `value` is not being assigned, but is interpolated into the pattern
  # with the value it was given before, in this case `4`.
when [value, <(value*2)>] =: [10, 20]
  # In this case, `value` is first being assigned as a new variable, so the
  # interpolation that follows will use that value instead, causing this
  # match to succeed.
end
