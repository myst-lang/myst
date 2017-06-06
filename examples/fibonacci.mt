# Recursive fibonnaci calculation.
#
# The following code shows how pattern matching can be used to create a
# type-safe implementation of a fibonnaci calculator.

# Define the base cases for the fibonacci sequence.
def fib(0); 1; end
def fib(1); 1; end
# For any other integer, use the equation a_n = a_n-1 + a_n-2
def fib(n : Integer)
  return if n < 0
  fib(n-1) + fib(n-2)
end

# Only integers are allowed as fibonnaci indices. Any other argument type
# is invalid, but we can avoid raising an error directly by defining a
# catch-all handler function that simply prints out "invalid argument".
#
# This is largely unecessary, but shows the utility and flexibility of
# pattern-matching in function heads.
def fib(arg)
  puts "#{arg} is not a valid argument for fibonnaci!"
end


fib(1)        #=> 1
fib(6)        #=> 8
fib("hello")  #=> "hello is not a valid argument for fibonnaci!"



# Obviously, calculating fibonnaci recursively is slow. It can easily be sped
# up using memoization to avoid calculating the same numbers more than once.

numbers = []
numbers[0] = 1
numbers[1] = 1

def fib(n : Integer)
  return if n < 0
  numbers[n] ||= fib(n-1) + fib(n-2)
end
