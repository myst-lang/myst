x = 5

until x == 0
  IO.puts(x)
  x = x - 1
end

while fib(x) < 10
  IO.puts(fib(x))
  x = x + 1
end
