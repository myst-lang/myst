# `break` will return from the function the block was passed to. If a value is
# given to the `break`, it will be used as the return value from the function.
# If no value is given, the result will be `nil`.
result = [1, 2, nil].each() do |elem|
  when elem == nil
    break :err
  end
end

IO.puts(result) #=> :err


# `next` will return from the current call to the block, with an optional value
# as the return value. If no value is given, the block will return `nil`.
#
# The following outputs only non-nil entries from the list. In this case, that
# means the only output will be `2`.
[nil, 2, nil].each() do |elem|
  when elem == nil
    next
  end

  IO.puts(elem)
end


# `return` is not allowed within a block, primarily because the semantics start
# to become more confusing, as `return` would cause an immediate exit from the
# block itself, the function that called it, _and_ the function that _provided_
# the block. Instead, the third exit is to be performed separately by users.
