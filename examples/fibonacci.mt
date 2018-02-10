# Recursive fibonnaci calculation.
#
# The following code shows how pattern matching can be used to create a
# type-safe implementation of a fibonnaci calculator.

# Define the base cases for the fibonacci sequence.
def fib(0); 0; end
def fib(1); 1; end
# For any other integer, use the equation a_n = a_n-1 + a_n-2. However, negative
# integers are invalid, so only accept positive ones.
def fib(n : Integer)
  fib(n-1) + fib(n-2)
end

# Only integers are allowed as fibonnaci indices. Any other argument type
# is invalid, but we can avoid raising an error directly by defining a
# catch-all handler function that simply prints out "invalid argument".
#
# This is largely unecessary, but shows the utility and flexibility of
# pattern-matching in function heads.
def fib(arg)
  arg.to_s + " is not a valid argument for fibonnaci!"
end


STDOUT.puts(fib(1))        #=> 1
STDOUT.puts(fib(6))        #=> 8
STDOUT.puts(fib("hello"))  #=> "hello is not a valid argument for fibonnaci!"



# Obviously, calculating fibonnaci recursively is slow. It can easily be sped
# up using memoization to avoid calculating the same numbers more than once.

numbers = [1, 1]

def fib(n : Integer)
  numbers[n] ||= fib(n-1) + fib(n-2)
end
