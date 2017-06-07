# Syntax

Myst's syntax is largely inspired by both Ruby and Elixir. The two primary goals of the syntax are minimal ambiguity and minimal punctuation. The meaning of a Myst expression should always be immediately clear, and the syntax should flow like the thought behind it.

Unlike Python, however, Myst does not aim to have a minimalistic _set_ of syntax. High-level constructs are provided to simplify the expression of complex thoughts.


## Comments

Comments in Myst are the same as pretty much every other modern language, using a hash character (`#`) to comment out everything until the next newline character.

```ruby
# This is a comment
#
# Blank comment lines are respected.
some_expression # now a comment
```

The comment syntax `#=>` should be used to show the expected result of an expression. For example:

```ruby
1+1 #=> 2
```

Note that this is purely convention, and is not enforced by the language in any way.


## Keywords

The following words are reserved in Myst for use by the language. Usage of a keyword outside of an expected location will result in a `KeywordError`. The meaning of these keywords is covered by sections later in this document.

```
and
begin
break
continue
def
elif
else
end
ensure
if
or
require
rescue
return
unless
until
while
with
yield
```


## Literals

Literals are representations of values that never change. Myst has literals for various primitive types, as well as a few literal constructs for collection types (lists, maps, etc.).

```ruby
# Integers
1
# Decimals (interpreted as floats)
1.0
# Strings are character sequences wrapped in double quotes. Every string
# literal represents a unique object.
"hi"
# Single quotes around a character are interpreted as a single character.
# Every character literal represents a unique object.
'hi'
# Symbols are prefixed with a colon. Symbols with the same name
# represent the same object.
:hi
# Boolean literals are always written in lowercase.
true
false
# The nil literal represents a single object with no value.
nil
```

Any character sequence that does not match a keyword or a literal structure is considered an identifier. Identifiers name variables, data types, and the casing of identifiers is used to show their intended usage. Identifiers must start with an alphabetic character or an underscore, and can be followed by any number of alphanumeric characters or underscores.

```ruby
# variables and functions should be written using snake_case.
x
var
multi_word_variable
_private_var
# acronyms and initialisms should be consolidated into a single group.
http_request
ssn

# type names should be written in UpperCamelCase.
Map
List
CustomDataType
# acronyms and initialisms should be written in all-caps.
HTTPServer
XMLElement

# non-type constants should be written in SCREAMING_CASE
CONFIG
WEBSITE_DOMAIN
API_VERSION
```

Identifiers that start with an uppercase letter are enforced to be constant. That is, they can only be assigned once. Attempting to re-assign a constant will result in a `ConstantReassignmentError`.

Identifiers can also be prefixed with modifiers that affect their meaning in some contexts. These will be covered later on in this document, but the same rule for naming applies.


## Collection Literals

Collection literals are used to build collection objects without having to name the type of the collection. Elements in a collection are separated by commas, and can be distributed across multiple lines as long as each line ends with a comma.

```ruby
# Lists are created by listing expressions in square brackets.
[1, 2, 3]
# Lists can be arbitrarily nested, and contain values of any type.
[1, "hello", [:nested, true], nil]

# Maps are created by specifying keys-value pairs in curly brackets.
# By default, keys are symbols, with the prefix colon becoming a suffix.
{key: value, another: "hello"}
# To use a key with a different type, or to interpret the key name from
# an expression, wrap the key with angle brackets:
{
  normal:     true,   # the key is the symbol `:normal`
  <"hello">:  'h',    # the key is evaluated as the string "hello"
  <2*3>:      6,      # the key is evaluated as the integer `6`
  <[1, 2]>:   :list,  # the key is the list [1, 2]
}
```

General convention for collection literals is to insert spaces between elements, but leave the outer elements directly touching the surrounding punctuation. This particularly helps disambiguate Map literals from blocks, which can also use the curly bracket syntax. For multi-line collection literals, every element should be on its own line, and every line should be indented from the surrounding punctuation by one indentation level.

Multi-line Map literals with multiple keys should left-align their values for easier mental scanning.


## Operations

Operations are expressions that with one or two operands and an operator. The operands are then evaluated together using the operator to create a result. The precedence and semantics of operations follow [C-style operator precedence](https://en.wikipedia.org/wiki/Order_of_operations#Programming_languages) and standard mathematic precedence, however, only the subset of operations listed here are supported. Notably, these lack the bitwise operations. Assignment operations are covered later on.

```ruby
# Logical operations
true && false #=> false
true || false #=> true
# Comparison operations
1 <  2        #=> true
1 >  2        #=> false
1 == 2        #=> false
1 != 2        #=> true
2 <= 2        #=> true
2 >= 2        #=> true
# Arithmetic operations
1 + 1         #=> 2
2 - 1         #=> 1
# Multiplicative operations
2 * 2         #=> 4
2 / 2         #=> 1
# Unary operations
+1            #=> 1
-1            #=> -1
!true         #=> false
```

Note that logical operations (`&&` and `||`) are short-circuiting, meaning if the result is determined by the first operand, the second operand will not be evaluated. To avoid this behavior, use the textual alternatives `and` and `or`, respectively.

Also note that the result of logical operations is not a boolean `true` or `false`, but rather the value that determined the result. For example, the expression `1 && 1` returns the integer `1`, and the expression `nil || "hello"` returns the string "hello", because integers and strings are truthy values.


# Assignments

Assignments in Myst come in two forms. The first is simple assignment as it appears most common languages today, using a single equals sign (`=`) to assign the right-hand-side expression's value to the left-hand-side. Myst also supports conditional assignment, multiple assignment, and decompositional assignment, as shown in the examples below.

```ruby
# normal assignment
x = 2
array = [1, 2, 3]

# conditional assignment
# ||= only assigns if the left-hand-side is nil
x = nil
x ||= 5 #=> `x` is now 5.
x ||= 8 #=> `x` is still 5.
# &&= only assigns if the left-hand-side is NOT nil
x = nil
x &&= 5 #=> `x` is still nil.
x = 5
x &&= 2 #=> `x` is now 2.

# multiple assignment: assign multiple variables in one statement
a, b, c = 1, 2, 3

# decompositional assignment: assign list elements to separate variables
# this is equivalent to the multiple assignment above
a, b, c = *array
# to ignore unwanted elements, use an underscore
a, _, c = array

# variadic decomposition: collect multiple elements into one variable
head, *rest = [1, 2, 3] #=> `head` is 1, `rest` is [2, 3]
a, *_, c = [1, 2, 3, 4] #=> `a` is 1, `c` is 3
```

The second form of assignment is akin to the [match operator in Elixir](https://elixir-lang.org/getting-started/pattern-matching.html#the-match-operator), enabling structured decomposition and pattern-matching on arbitrary expressions.

Elixir _only_ implements pattern-matched assignment, and so it uses the single equal sign as the operator. However, since Myst supports both simple _and_ pattern-matched assignment, it distinguishes them by using a distinct "matching" operator, `=:`, to designate pattern-matched assignment.

Pattern-matched assignment creates an expectation that the value on the right-hand-side will conform to the structure expressed on the left-hand-side. If the structure is not matched, a `MatchFailure` is raised with the right-hand-side and the failing match as members.

Pattern-matched assignment could be considered a misnomer, as an assignment is not actually required. In fact, pattern-matching is often useful for simply expecting a value out of an expression.

```ruby
# Pattern matching without assignment
a = 1
1 =: a #=> success, and execution continues
2 =: a #=> failure, so a `MatchFailure` is raised.

# Destructuring lists
array = [1, 2, 3]
[1, a, 3] =: array #=> success, `a` is set to 2
[*a, 3]   =: array #=> success, `a` is set to [1, 2]
[a, *_]   =: array #=> success, `a` is set to 1
[1, 2]    =: array #=> failure, array is not fully matched
# elements can be interpolated similar to map interpolation
x = 1
[<x>, *_] =: array #=> success, x is not assigned

# Destructuring maps
map = {a: 1, b: 3, <3>: "hello"}
# matching is not exhaustive, not all keys have to be matched
{a: a, b: b}  =: map #=> success
{c: 2}        =: map #=> failure, `c` is not a key in `map`
# key interpolation works like normal
x = 3
{<x>: a} =: map
# values can also be interpolated
{b: <x>} =: map #=> equivalent to `{b: 3} =: map`
```


# Flow control

Myst's flow control structures are almost directly taken from Ruby. There are no native discrete iteration constructs (e.g., `for..in` or `foreach`).

```ruby
# conditions as blocks
if a
  # only if `a` is truthy
end
unless b
  # only if `b` is falsey
end
# conditions as suffixes
a = 1 if 2 == 2
a = 1 unless 1 == 2
# return immediately with optional arguments
return
return a, b
# break from the current scope with an optional value
break
break a, b
# yield to a block argument given to the current scope with an optional value
yield
yield a, b
# skip the rest of the current scope, where the scope may execute again
next
next a, b
```


# Functions

Functions in Myst are a combination of Ruby's argument and block syntax with Elixir's pattern matching semantics.

```
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
```

Pattern matching allows for function overloads with equal arity. If no function head matches all of the call arguments, a `FunctionMatchError` will raise.


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
