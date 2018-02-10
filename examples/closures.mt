def foo(&block)
  block
end

a = 1

# The block binds with the scope in which it is defined, so `a` references the
# local variable `a` defined above.
foo{ a = a + 1 }

# As a result, executing the block changes the value of `a` _outside_ of the
# block, meaning it's value is now 2.
STDOUT.puts(a) #=> 2
