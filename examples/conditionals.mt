# Unlike C-based languages, conditional statements do not use parenthesis
# around their condition. Instead, a single space is used to delimit from the
# keyword.

# Suffix conditionals are not yet supported, but they are on the roadmap.


# This example also shows a basic function definition and call. This will be
# expanded upon in another example.
def fib(n)
  if n <= 1
    1
  else
    fib(n-2) + fib(n-1)
  end
end

puts(fib(10))

unless 1 == 2
  puts("1 is not 2")
end

x = 5

until x == 0
  puts(x)
  x = x - 1
end

while fib(x) < 10
  puts(fib(x))
  x = x + 1
end
