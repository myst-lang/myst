x = 5

until x == 0
  STDOUT.puts(x)
  x = x - 1
end

while fib(x) < 10
  STDOUT.puts(fib(x))
  x = x + 1
end
