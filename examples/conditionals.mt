def fib(n)
  if n == 0
    1
  elif n == 1
    1
  else
    fib(n-2) + fib(n-1)
  end
end

if 1 < 2
  fib(0)
  fib(8)
end
