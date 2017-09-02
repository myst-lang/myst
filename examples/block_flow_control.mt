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
