def fib(n)
  if n == 0 || n == 1
    1
  else
    fib(n-2) + fib(n-1)
  end
end

fib(10)
