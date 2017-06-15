def fib(n)
  if n == 0 || n == 1
    1
  else
    fib(n-2) + fib(n-1)
  end
end

puts(fib(10))
