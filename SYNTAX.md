```ruby
# Hash comments.
#   a modern default

# Primitive types
1     # integer
1.0   # float
"hi"  # string
'hi'  # character
:hi   # symbol
true  # boolean
nil   # undefined value


# Classic infix algebra (no exponents)
((1 + 2 - 3) * 5 / 6)


# Logical operations
true && false || true && true


# Variables
a   # A local variable
B   # A constant (single assignment)


# Collection Literals
# Arrays/lists (variable size)
[a, b, c]
# Tuples (fixed size)
{a, b, c}
# Maps. <a> evaluates `a` and uses that as the key
{a: b, c: d, <a>: e}


# Assignment
# normal assignment
x = 2
# conditional assignment
a ||= b  # if a.nil?; a = b
a &&= b  # unless a.nil?; a = b
# multiple assignment
a, b = 1, 2
# selective assignment
a, _, b = 1, 2, 3
# compositive assignment
a, *_, b = 1, 2, 3, 4
# decompositive assignment
a, b, *c = [c, d, e, f]
# pattern-matched assignment
[1, b] =: [1, 2]
{a: a, c: c} =: {a: 1, b: 2, c: 3}
# Flow control
if a
  # only if `a` is truthy
end
unless b
  # only if `b` is falsey
end
# return immediately with an optional value
return a
# break from the current scope with an optional value
break a
# yield to a block argument given to the current scope with an optional value
yield a
# skip the rest of the current scope, where the scope may execute again
next a
with a == nil
  # `a` is only defined in this scope
end


# Functions
# argument order
def func(positional, b=1, *args, named: 2, d:, **kwargs); end
# decompositive arguments
def func([1, b], {a: a, <b>: 2}); end
# pattern-matched arguments
def func(a, nil, b=.is_a?(B), c: .not_nil?); end
# type restriction shorthand
def func(a=:default : Symbol, b: 3 : Integer)
# procs/lambdas are equivalent
->{ |a, b| }
def func(a, &explicit_block); explicit_block.call(); end
# function call with block
func &a_proc
func{ |a, b=.not_nil?| }
func do |a, b : B)|
end
# Note: Pattern matching allows for function overloads with equal arity. If no
# function head matches all of the call arguments, a NoMethodError will raise.


# Blocks
# basic scope block
begin
  # try this first
rescue <ExceptionType>: ex
  # if `begin` fails with ExceptionType, do this
rescue ex
  # if `begin` or `resuce` fails with any exception.
  # `ex` is not required
else
  # if `begin` ran with no exceptions
ensure
  # run this no matter what
end
# Note: rescue/else/ensure can also be used with blocks created by `do`.


# Dependency loading, adopted from Ruby
require "a_library"
require "a/local/file"
```
