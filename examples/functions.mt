# Functions are defined using the `def` keyword followed by an identifier for
# the name of the function. If the function accepts parameters, they are listed
# in parentheses immediately following the function name.
#
# Functions can contain 0 or more expressions in their body. By default, the
# last expression that gets evaluated in a function body will be used as the
# return value.
#
# The function below is named `add`, takes two parameters (`a` and `b`) and
# returns the result of adding those two together
def add(a, b)
  a + b
end

x = 1
y = 2

# Functions are called by specifying a name and passing arguments in
# parentheses. If the function is to be called with no arguments, the
# parentheses may be omitted.
STDOUT.puts(add(4, add(x, y))) #=> 7


# Functions implicitly close over the scope that they are defined in. For
# example, a function defined inside of a module will always be able to
# reference other variables and functions defined in that module, no matter
# where it is called from.
module Container
  some_value = 10

  def return_some_value
    some_value
  end
end

STDOUT.puts(Container.return_some_value()) #=> 10
