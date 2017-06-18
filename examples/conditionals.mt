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
