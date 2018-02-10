# `return` will cause the current function to exit immediately. If a value is
# given to `return` it will be used as the result of the function. This is
# complementary to the implicit return values of functions (the last expression
# evaluated when running the function).
#
# The following function is a contrived example that should really be handled
# with pattern matching for the arguments, but shows how `return` can be used
# to exit a function early.
list = []
def add_if_not_nil(element)
  unless element
    return nil
  end

  list = list + [element]
end

STDOUT.puts(add_if_not_nil(1))   #=> [1]
STDOUT.puts(add_if_not_nil(nil)) #=> nil
# Because of the early return when called with `nil`, `list` should only
# contain the `1` that was added first.
STDOUT.puts(list) #=> [1]

# `break` will return from the function the block was passed to. If a value is
# given to the `break`, it will be used as the return value from the function.
# If no value is given, the result will be `nil`.
i = 0
result = [1, 2, nil, 4, 5].each() do |elem|
  when elem == nil
    break :err
  end
  i = i + 1
end

STDOUT.puts(result) #=> :err
# Because `break` caused `each` to exit before iterating all of the elements,
# `i` was only incremented twice.
STDOUT.puts("Iterations: " + i.to_s()) #=> 2


# `next` will return from the current call to the block, with an optional value
# as the return value. If no value is given, the block will return `nil`.
#
# The following outputs only non-nil entries from the list. In this case, that
# means the only output will be `hello`.
[nil, "hello", nil].each() do |elem|
  when elem == nil
    next
  end

  STDOUT.puts(elem)
end


# `return` is not allowed within a block, primarily because the semantics start
# to become more confusing, as `return` would cause an immediate exit from the
# block itself, the function that called it, _and_ the function that _provided_
# the block. Instead, the third exit is to be performed separately by users.
