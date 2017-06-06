# Building a Compiler

This document provides a high-level overview of the different components in a compiler for a dynamic language. Namely, these are the Virtual Machine, Lexer, Parser, and Visitors.


## Virtual Machine

The Virtual Machine (VM) is the base of Myst. It reads in a stream of bytecode instructions and executes them as it goes. The result of compiling a Myst program is a bytecode stream. In most cases, this is simply passed directly to the VM and executed immediately, but this bytecode could also be saved off into a file and read directly into the VM at a later time.

While the term "Virtual Machine" often carries a heavy-weight connotation (thanks to the prevelance of programs like VirtualBox and Parallels for Mac), a Virtual Machine simply is any abstraction over the hardware that code is eventually executed upon. The JVM is probably the first VM that comes to mind when talking about VMs specifically for programming languages, but most dynamic languages implement a VM to improve portability (e.g., Ruby, Python, and Lua, to name a few).

In Myst, the VM is little more than a Universal Turing Machine, with only a few added features to make implementing high-level features simpler and faster. These features are covered quickly below, but are largely unimportant in this overview.

In this sense, the components of Myst and it's Virtual Machine are analagous to those in a static, compiled language and _real_ machine. For example, C can be compiled to Assembly with gcc, which subsequently gets interpreted (again, by gcc) to machine-specific bytecode, which is then directly interpreted by the real machine. These chains of compilation/interpretation are often represented as [Tombstone Diagrams](https://en.wikipedia.org/wiki/Tombstone_diagram).

### Bytecode

Myst Bytecode closely resembles Assembly language. As mentioned above, it is little more than an implementation of a Universal Turing Machine. A Bytecode stream is made up of individual Instructions, each of which specifies a command, and optionally some arguments to use for that command. Take a look at this example of a Myst expression and the resulting bytecode:

```myst
# Myst source
2*4 + 8/16

# Myst bytecode
PUSH      2
PUSH      4
MULTIPLY
PUSH      8
PUSH      16
DIVIDE
ADD
```

If you have ever used [Reverse Polish Notation](https://en.wikipedia.org/wiki/Reverse_Polish_notation), the bytecode probably looks very familiar, and that's because it essentially is a textual representation of RPN. The `PUSH` instructions add values to the program stack, while the `MULTIPLY`, `DIVIDE`, and `ADD` instructions pop values from the stack, calculate a result, and push that back onto the stack.

Another good example of Myst bytecode is function calls:

```myst
# Myst source
add(1, 2, 3)

# Myst bytecode
PUSH 3
PUSH 2
PUSH 1
FUNC_CALL add
```

This example shows that Myst bytecode is derived from [`cdecl` calling conventions](https://en.wikipedia.org/wiki/X86_calling_conventions#cdecl), where arguments to functions are pushed onto the stack, then the function being called with `FUNC_CALL` pops the values from the stack to use them.

These are obviously trivial examples, but with this knowledge, it shouldn't be too difficult to learn how other bytecode instructions are implemented to utilize the stack and composed together to implement higher-level functionality.

For a complete reference of the instructions available in Myst's bytecode, see the [Bytecode-specific README]().

### Stack

As alluded to in the Bytecode section, the Myst VM uses a stack for immediate memory while executing bytecode. There are other Random Access Memory interfaces available to manage more permanent values, but all instructions interact with the stack in some way.

Some examples:

- `PUSH <value>`: push `value` onto the top of the stack.
- `ADD`: take the top two values from the stack, add them together, and push the result back onto the stack.
- `STORE <variable>`: Pop the top value from the stack and store its value into `variable`.
- `FUNC_CALL <func>`: the arguments to `func` are expected to be on the stack in order. The first instructions of `func` will then pull the arguments from the stack into their local variables using `STORE`.

Every entry in the stack is an `MTValue`, the union of all native types in Myst.


## Lexer

The Lexer is the first step in compiling a Myst program. It is responsible for converting the raw text of the source code into a series of tokens that are fed to the parser for analysis. The Lexer makes no guesses about what the structure of a program should be, it only understands the different types of tokens that the language allows and the characters that form them.

Consider this non-sensical, invalid line of Myst code:

```myst
add(1 + / 3 }true if
```

Obviously, this code does not make sense semantically, but the Lexer does not know that, it just sees a series of characters and tries to classify them together. Since the above code only contains valid tokens, the result of running the Lexer on it would be a stream of tokens, which in this case looks like this:

```
[identifier, left parenthesis, integer literal, plus, slash,
integer literal, right brace, boolean literal, if keyword]
```

Since the Lexer is only concerned with the tokens present in the source, it can always been done in one pass with no backtracking. As such, it's also possible to stream tokens to the Parser as they are needed, rather than reading all of the tokens and only then starting to parse them.

In smaller codebases, this doesn't have much of an effect, as the time spent lexing the source code is insignificant compared to the other steps in compilation. However, in larger codebases and codebases with errors in them, streaming tokens can result in less memory overhead from storing tokens, and can identify errors syntax and semantic errors more quickly (before the entire source has even been read).


## Parser

The Parser is the second step in compiling a Myst program. It reads tokens from the Lexer, determines their meaning in the context of the surrounding tokens, and creates an [Abstract Syntax Tree](https://en.wikipedia.org/wiki/Abstract_syntax_tree) representing the meaning of the program in an easily-understandable, un-ambiguous structure. While the Parser determines the _meaning_ of tokens, it does _not_ assert the validity of that meaning, and so it is possible to correctly parse a program that contains semantic errors, but after parsing, the syntactic validity of the source is guaranteed.

Specifically, Myst implements an LL(1) [Recursive Decent Parser](https://en.wikipedia.org/wiki/Recursive_descent_parser), a simple top-down parser that steps through tokens iteratively, only determining their meaning after all tokens for a node in the tree (formally, a "production") have been read. This differs from LR parsers in that once a token has been parsed, it's meaning is determined and will not be changed, and also differs from bottom-up parsers in that no guesses about meaning are made.


Consider the following token stream from lexing an expression:

```
# add(1+2, 6/3)
[identifier, left parenthesis, integer literal, plus, integer literal,
comma, integer literal, slash, integer literal, right parenthesis]
```

The first thing the Parser sees is an `identifier` (the value of which is `add`), so the parser knows that the expression is either a variable access/assignment, or a function call. From there, it reads the left parenthesis, finalizing that the expression is a function call. Now, the parser knows to expect an argument list for the function, so it continues with that expectation until finding the closing right parenthesis at the end of the expression. The resulting syntax tree looks like this:

```
CallExpression
├─Identifier("add")
└─ExpressionList
  ├─BinaryExpression│+
  │ ├─IntegerLiteral(1)
  │ └─IntegerLiteral(2)
  └─BinaryExpression│/
    ├─IntegerLiteral(6)
    └─IntegerLiteral(3)
```

As is probably apparent from the size of this tree compared to the length of the expression in Myst, syntax trees can quickly become very large and complex, making them difficult for a human to interpret as a whole. Thankfully, we hardly ever consider the tree as a whole, and instead look at the individual nodes and their immediate children to determine their meaning.


## Visitors

Where the Virtual Machine is the driver of code _execution_, Visitors are the drivers of the code _compilation_. They are responsible for walking the syntax tree that comes out of the parser and performing actions at each node. These actions potentially include emitting bytecode instructions, printing out a visualization of the tree for debugging, transpiling, automatic formatting, and more. The most important Visitor for compiling is obviously the bytecode emitter, since that is what generates the instructions for the VM to use at runtime.

The essence of the VM's visitor is defining the instructions that correlate to the meaning of a node, and recursing through that node's children to create a flat list of instructions that represent the same intent.

A nice example of this behavior is the `BinaryExpression` node, which first visits it's two children - `left` and `right` - the result of which is a set of instructions that puts the operand values for the expression at the top of the stack. Then, the visitor looks at the `operator` for the node and emits the appropriate instruction for that operation. A simple example is adding three integer literals.

```
# Using the expression `1*2+3`, the syntax tree looks like this:
# BinaryExpression|+
# ├─IntegerLiteral(1)
# └─BinaryExpression|+
#   ├─IntegerLiteral(2)
#   └─IntegerLiteral(3)

# The left operand to the top expression is just an integer literal, which
# emits the `PUSH 1` instruction.
PUSH  1
# The right operand, however, is itself a binary expression, so it will also
# recurse to emit instructions. Both of it's children are integer literals, so
# visiting the operands simply results in two `PUSH` instructions.
PUSH  2
PUSH  3
# The lower binary expression's operator is a minus (`-`), so it emits a
# `SUBTRACT` instruction.
SUBTRACT
# Finally, the top expression's operator (`+`) is examined and the `ADD`
# instruction is emitted.
ADD
```

Looking at this bytecode, the instruction definition for a `BinaryExpression` node is just the instruction corresponding to the operator of the expression (e.g., `ADD` or `SUBTRACT`), while the definition of an `IntegerLiteral` node is simply a `PUSH` instruction with the value of the literal. Visiting the nodes in the tree in order results in a full program in bytecode that represents the same meaning.


## Conclusion

This has been an attempt at quickly covering the internals of a compiler, using the Myst compiler as an example. Hopefully it has been provided some insight into the process that a compiler goes through to transform source code into something executable.

There's a myriad of resources available on the internet about writing a simple interpreter, crafting a hand-written lexer/parser, or even writing a small VM. The problem I have with all of these resources is that there is a pretty apparent gap between these individual, educational lessons and real, practical examples of compilers in the wild.

Most interpreter examples, for instance, use a simple tree-walking execution style, where the AST is the final program. This is great for simplicity and focusing on how ASTs can be analyzed, but is painfully slow, and thus impractical for any real application.

Additionally, most Virtual Machine guides explain the process of interpreting bytecode effectively, but don't show how to take source code from a higher level language and transform it into the bytecode.

That middle step of converting the AST from an interpreter example into the bytecode for a VM is often missing, meaning that many newcomers don't understand how to go from one to the next, and get stuck, frustrated, and often dispirited about continuing to learn and improving their learning projects to become practical compilers.

If you still have any questions, feel free to [open an issue about it](https://github.com/myst-lang/myst) or hop in the [Myst Language Discord server](not yet) so I can improve this guide or the Myst language to make it more readily accessible to everyone.
