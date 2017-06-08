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

Identifiers can also be prefixed with modifiers that affect their meaning in some contexts. These will be covered later on in this document, but the naming rule for variables and functions should be applied for them.


## Collection Literals

Collection literals are used to build collection objects without having to name the type of the collection. Elements in a collection are separated by commas, and can be distributed across multiple lines as long as each line ends with a comma.

```ruby
# Lists are created by listing expressions in square brackets.
[1, 2, 3]
# Lists can be arbitrarily nested, and contain values of any type.
[1, "hello", [:nested, true], nil]
# Insert an existing list into another using a splat.
list1 = [1, 2, 3]
list2 = [0, *list1, 4] #=> [0, 1, 2, 3, 4]

# Maps are created by specifying keys-value pairs in curly brackets.
# By default, keys are symbols, with the prefix colon becoming a suffix.
{key: value, another: "hello"}
# To use a key with a different type, or to interpret the key name from
# an expression, wrap the key with angle brackets:
a = :variable
{
  normal:     true,   # the key is the symbol `:normal`
  <"hello">:  'h',    # the key is the string "hello"
  <2*3>:      6,      # the key is the integer `6`
  <[1, 2]>:   :list,  # the key is the list [1, 2]
  <a>:        :var,   # the key is the symbol `:variable`
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


## Assignments

Assignments in Myst come in two forms: simple assignment and pattern-matched assignment.

### Simple assignment

The first is simple assignment as it appears most common languages today, using a single equals sign (`=`) to assign the right-hand-side expression's value to the left-hand-side. Myst also supports conditional assignment, multiple assignment, and decompositional assignment, as shown in the examples below.

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
a, *_, c, d = [1, 2, 3, 4, 5] #=> `a` is 1, `c` is 4, `d` is 5
```

### Pattern-matched assignment

The second form of assignment is akin to the [match operator in Elixir](https://elixir-lang.org/getting-started/pattern-matching.html#the-match-operator), enabling structured decomposition and pattern-matching on arbitrary expressions.

Elixir _only_ implements pattern-matched assignment, and so its use of the single equal sign as the operator is straightforward, though not intuitive for many newcomers. Because of this, and because Myst supports both simple _and_ pattern-matched assignment, it distinguishes them by using a distinct "matching" operator (`=:`) to designate pattern-matched assignment.

Pattern-matched assignment creates an expectation that the value on the right-hand-side will conform to the structure expressed on the left-hand-side. If the structure is not matched, a `MatchFailure` is raised.

In some ways, pattern-matched assignment could be considered a misnomer, as an assignment is not actually required. In fact, pattern-matching is often useful for simply expecting a value out of an expression.

```ruby
# Pattern matching without assignment
a = 1
1 =: a #=> success, and execution continues
2 =: a #=> failure, so a `MatchFailure` is raised.
```

The above is essentially shorthand for the following:

```ruby
a = 1
raise MatchFailure.new(1, a) unless 1 == a
raise MatchFailure.new(2, 1) unless 2 == a
```

The more common use case of pattern matching, however, is destructuring collections into various parts. This is similar to multiple assignment, but also supports destructuring maps, and interpolation of values to match against.

```ruby
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
# values can also be interpolated. Without the brackets, `x` would capture any
# value, rather than interpolating the value of `x` as the expected structure.
{b: <x>} =: map #=> equivalent to `{b: 3} =: map`
```


## Flow control

Myst's flow control structures are almost directly taken from Ruby. However, there are no discrete iteration constructs (e.g., `for..in` or `foreach`).

```ruby
# conditions as blocks
if a
  # only if `a` is truthy
elif b
  # only if `a` is falsey and `b` is truthy
else
  # only if neither of the above runs
end
unless b
  # only if `b` is falsey
end
# looping as a block
while a
  # do until `a` is falsey
end
until a
  # do as long as `a` is falsey
end
# conditions/looping as suffixes
a = 1 if 2 == 2
a = 1 unless 1 == 2
a += 1 while a < 10
a -= 1 until a < 10
# Jumping dispatch
case x
when y
  # do when y =: x
else
  # do when no `when` runs
end
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


## Functions

Functions in Myst are an amalgamation of Ruby's parameter layout syntax with Elixir's pattern matching semantics and guard clauses mixed in. There are three possible syntaxes for declaring a function parameter:

```ruby
# For normal positional parameters, everything but `name` is optional
name = default : Type|guard_expression
# For named parameters a colon is used in place of the equals sign,
# with no space after the name
name: default : Type|guard_expression
# For pattern-matched parameters, `pattern` is the only requirement.
pattern =: name = default : Type|guard_expression
```

### Parameter layout
In general, parameters for a function are defined in the following order:

1. Required positional parameters
2. Optional positional parameters
3. Optional capture of remaining position parameters
4. Named parameters (optional and required)
5. Optional named parameters
6. Optional capture of remaining named parameters
7. Optional explicit block parameter

In code, using all of these argument types together would look like this:

```ruby
def func(positional, b=1, *args, named: 2, d:, **kwargs, &block); end
```

In the above function head, `args` will be a zero-or-more element list, collecting any remaining positional arguments after the first 2 have matched (`a` and `b`). `kwargs` will similarly be a Map of any named arguments that are not matched to any of the preceding parameters (`named` and `d`).

Additionally, `b` is an optional parameter. If it is not assigned a value by the function call, it will default to the value `1`. `named:` is also an optional parameter. If it is not assigned a value, it will default to `2`. Notice that the order of named parameters is not important; named parameters with default values may appear before required named parameters.

### Pattern matching

Function parameters also support the destructuring syntax used in pattern-matching assignment. In fact, all parameters in all functions are given their values using the matching operator, for functions that only name parameters and default values, this makes no real difference, as the left-hand-side is a catch-all variable expression. However, destructuring parameters in function heads can be extremely powerful.

```ruby
def func(0, [1, b], {a: a, <"hello">: 2}); end
```

This function matches a call with three positional arguments. The first element must be equal to `0`. The second must be a two-element list whose first element is equal to `1`, and the third must be a map with the keys `:a` and `"hello"`. The value of `:a` in the third argument is captured into the variable `a`, and the value of `"hello"` in the third argument must be equal to 2.

If any of these constraints are not met, the function call will raise a `FunctionMatchFailure`.

Pattern-matched arguments can also be explicitly pattern matched and captured as a whole using a matching operator in the function head:

```ruby
def func(0, [1, b], {a: a, <"hello">: 2} =: map); end
```

In this case, all of the constraints of the previous function head must be met, but the original value of the second argument will also be captured into `map`. The match operator (`=:`) is used to distinguish a pattern constraint from a default value, which uses a single equals sign (`=`). The semantics of the expression also match normal pattern-matching semantics, where any pattern is accepted and captured into the left-hand-side.

Note that because of this syntax, pattern-matching is only supported for positional arguments. However, this is only because a clean, unambiguous syntax for matching named arguments has not been found. If one arises, it will likely be accepted.

### Guard clauses

A unique syntax feature of Myst is infixed guard clauses. These are arbitrary expressions that constrain the values of parameters inside of the function. These clauses are expressed using a pipe character (`|`) between the parameter name and the expression. The parameter name will be syntactically copied to the beginning of the expression, so any binary expression or function call is a valid guard clause. For example:

```ruby
def func(a, b| < 1, c=1|.truthy?, d:|.not_nil?); end
```

This function head has three guard clauses. For the function to match, the second positional argument, `b`, must make the expression `b < 1` be truthy; the third, `c`, must make the expression `c.truthy?` evaluate as truthy, and the named argument `d` must make the expression `d.not_nil?` be truthy.

### Type restriction

A shorthand for type restriction on parameters is also available:

```ruby
def func(a=1 : Integer, b: "hello" : String|.length > 3); end
```

This shorthand essentially acts as a guard clause of `.is_a?(T)`, where `T` is the type that is given in the restriction. The function head above matches when the first argument (`a`) is an Integer value and `b` is a String value whose length is greater than 3. Both parameters also have default values that will be used only if the parameters are not provided. If a value is provided for the parameter, but does not meet the type restriction, a `FunctionMatchFailure` is still raised, rather than using the default parameter.

### Procs

A `Proc` is an anonymous function that can be defined anywhere, and called like a normal function with `.call()`. Proc definitions use a stab-arrow (`->`) operator to start their definition, followed by parameter declaration in parenthesis, then by a code block (`do...end` or `{...}`).

```ruby
proc1 = ->(a=1 : Integer| > 0, b : Integer) do; end
proc1.call(1, 2)
# Procs with no arguments still include the parenthesis
proc2 = ->() {}
proc2.call()
```

### Blocks as arguments

While a `Proc` can be assigned to a variable via simple assignment, a block is only allowed as a function argument. A function that accepts a block argument may either explicitly declare a block parameter as the last argument using an ampersand (`&`), or accept the argument implicitly by calling `yield` anywhere in the function body.

```ruby
def func(a, b, &block)
  # The given block is captured as a Proc.
  block.call(a)
  # Yielding with an explicit block is not allowed
  yield a #=> fails to compile
end
```

Taking a block implicitly requires no change to the function head:

```ruby
def func(a, b)
  yield a
  yield b
end
```

The above function yields to the given block twice. The first time, it is given an argument of `a`, and the second time, it is given an argument of `b`. Implicit blocks do not allow the function to capture the given block. If the block needs to be stored, it should be taken as an explicit argument.


### Call syntax

Now that we've seen all of the ways a function can be defined, we can fully cover how functions are called. In general, calls match the syntax of function heads, but do not include any of the guard clause or type restriction syntax. Consider this function definition:

```ruby
def func(positional, b=1, *args, named: 2, d:, **kwargs); end
```

A call to this function could take multiple forms:

```ruby
# only providing the required arguments
func(1, d: 2)
# providing all explicit arguments
func(1, 2, named: 3, d: 4)
# providing extra arguments, collected in `args` and `kwargs`.
func(1, 2, 3, 4, a: 5, named: 7, d: 8, e: 9)
#=> `args` is [3, 4], `kwargs` is {a: 5, e: 9}
```

Function calls can also use key interpolation for named arguments:

```ruby
def func(symbol: 1, <"string">: 2); end

x = "string"
y = :symbol
func(<x>: 3, <y>: 4)
```

To provide a block directly to a function, use either the `{}` or `do...end` block syntax immediately following the call:

```ruby
func(with, arguments) do |some, parameters: 1|
end
```

To pass an existing Proc to a function, or to convert an Object to a Proc, use an ampersand (`&`).

```ruby
proc1 = ->(some, parameters: 1) {}
func(with, arguments, &proc1)
```

Unlike most other languages with blocks, the two syntaxes for blocks are semantically identically. In languages like Ruby and Crystal, blocks specified with `{}` are implicitly _right_ associative, while blocks specified with `do...end` are _left_ associative, which can lead to confusion when parenthesis are omitted, so Myst enforces a single convention to simplify mental overhead.

Providing too many or too few arguments to a function will raise a `FunctionMatchFailure`. This also applies to block arguments. A function that _explicitly_ accepts a block argument will not match if a block is not provided. Functions that _implicitly_ accept blocks _will_ match without a block provided, but will fail if the function tries to `yield`.

### Overloading

Because functions in Myst allow for constraints on the values that are passed to a function, the language also allows functions to be defined multiple times. There are no cases where defining a function a second time will cause an error. In fact, redefining a function with the same constraints will still create a second version of the function.

When determining which function to use for a function call, Myst will attempt to match function heads in the order that they are defined in the source code. Once a function head is matched, that function is called, and matching stops. This makes it easy to create cascading restrictions on arguments, a good example of which is the [Recursive Fibonnaci implementation](examples/fibonnaci.mt).


## Exception handling

As you may have noticed from the previous sections, Myst has the concept of Exceptions, which means that they need to be handled in some way. The way that Myst allows developers to handle exceptions is most similar to Crystal, which is almost identical to Ruby in this regard.

### Raising

To start, exceptions in Myst are created using the `raise` keyword with an argument that is used as the exception object. For example, in the Pattern matching section, an example of a match operator equivalent was shown:

```ruby
raise MatchFailure.new(a, b) unless a == b
```

### Capturing

Once an exception has been raised, developers can capture it using a `begin...rescue...end` block. The default case catches all exceptions:

```ruby
begin
  # try this code
rescue
  # if an exception occurs, capture it and run this code.
end
```

This can be useful if the type of exception is not important and any error should be captured, though this is often not a good solution, as it makes attempting to solve the exception more difficult.

To help with that, `rescue` can define a parameter to capture an argument. This is a pattern-matched parameter, meaning that all of the pattern-matched parameter syntax from functions is supported:

```ruby
begin
  # try this code
rescue {callstack: callstack} =: ex : NoMethodError
  # deal with a `NoMethodError` exception
rescue ex : FunctionMatchFailure
  # deal with a FunctionMatchFailure
rescue
  # deal with any other error
end
```

If an Exception is not captured by any of the `rescue` clauses in the block, it is propogated up the callstack until it is captured. If it is captured, execution of the containing block continues with the next expression after the block.

Myst also supports two other clause types in `begin` blocks: `else` and `ensure`. These are only allowed to appear after all of the `rescue` clauses in a block, and if both are present, `else` must appear before `ensure`.

```ruby
begin
  # try this code
rescue
  # deal with any exceptions
else
  # if an exception was _not_ raised, run this code
ensure
  # run this code no matter what, even if the exception was not caught
end
```
