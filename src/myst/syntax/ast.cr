module Myst
  abstract class Node
    property  location      : Location?
    property  end_location  : Location?

    def at(@location : Location)
      self
    end

    def at_end(@end_location : Location)
      self
    end

    def at(node : Node)
      @location = node.location
      @end_location = node.end_location
      self
    end

    def at_end(node : Node)
      @end_location = node.end_location
      self
    end

    def at(node : Nil);     self; end
    def at_end(node : Nil); self; end

    def accept(visitor)
      visitor.visit(self)
    end

    def accept_children(visitor)
    end

    def class_desc : String
      {{@type.name.split("::").last.id.stringify}}
    end
  end


  # A No-op. Used as a placeholder for empty bodies, such as an empty method
  # definition or empty class body.
  #
  #
  class Nop < Node
    def_equals_and_hash
  end


  # A container for one or more expressions. The main block of a program will
  # be an Expressions node. Other examples include function bodies, module
  # bodies, etc.
  class Expressions < Node
    property children  : Array(Node)

    def initialize; @children = [] of Node; end
    def initialize(*children)
      @children = children.map{ |c| c.as(Node) }.to_a
    end

    def initialize(other : self)
      @children = other.children
    end

    def accept_children(visitor)
      children.each(&.accept(visitor))
    end


    def location
      @location || @children.first?.try &.location
    end

    def end_location
      @end_location || @children.last?.try &.end_location
    end

    def_equals_and_hash children
  end


  # Any literal node. This intermediate class allows the parser to easily
  # assert that a node is a literal, without worry about type expansion to
  # `Node+`, which would allow any Node type.
  class Literal < Node
  end

  # The `nil` literal.
  #
  #   'nil'
  class NilLiteral < Literal
    def_equals_and_hash
  end

  # A boolean literal.
  #
  #   'true' | 'false'
  class BooleanLiteral < Literal
    property value : Bool

    def initialize(@value); end

    def_equals_and_hash value
  end

  # Any integer literal. Underscores from the literal are removed from the
  # value stored by this node.
  #
  #   [0-9][_0-9]*
  class IntegerLiteral < Literal
    property value : String

    def initialize(@value); end

    def_equals_and_hash value
  end

  # A float literal. Same as above, but for values including decimals. Float
  # literals _must_ have a decimal value both before _and_ after the radix.
  #
  #   [0-9][_0-9]*\.[_0-9]+
  class FloatLiteral < Literal
    property value : String

    def initialize(@value); end

    def_equals_and_hash value
  end

  # A string literal. Any value wrapped in double quotes. Characters
  # immediately following a backslash are escaped.
  #
  #   '"' \w* '"'
  class StringLiteral < Literal
    property value : String

    def initialize(@value); end

    def_equals_and_hash value
  end

  # A string literal with interpolations. Any string that includes a
  # `<(...)>` construct will be considered an InterpolatedStringLiteral.
  #
  #   '"' [\w*(<()>)?]* '"'
  class InterpolatedStringLiteral < Literal
    property components : Array(Node)

    def initialize(@components=[] of Node)
    end

    def accept_children(visitor)
      components.each(&.accept(visitor))
    end

    def_equals_and_hash components
  end

  # A symbol literal. The value stored by this node does not include the
  # designating colon.
  #
  #   ':' name
  # |
  #   name ':'
  #
  # The second form only applies in some contexts (map entries, etc.).
  class SymbolLiteral < Literal
    property value : String

    def initialize(@value); end

    def_equals_and_hash value
  end

  # A List literal. Lists are always delimited by square braces, and may
  # contain any number of elements, delimited from each other by commas.
  #
  #   '[' [ expression [ ',' expression ]* ] ']'
  class ListLiteral < Literal
    property elements : Array(Node)

    def initialize(@elements = [] of Node)
    end

    def accept_children(visitor)
      elements.each(&.accept(visitor))
    end

    def_equals_and_hash elements
  end

  # A Map literal. Maps are always delimited by curly braces, and may contain
  # any number of entries, delimited from each other by commas.
  #
  #   '{' [ entry [ ',' entry ]* ] '}'
  #
  # Entries are dual values separated by a colon. The first value (the key)
  # may be either a name or a value interpolation (defined later).
  #
  #   name ':' expression
  # |
  #   interpolation ':' expression
  class MapLiteral < Literal
    property entries : Array(Entry)

    record Entry,
      key : Node,
      value : Node

    def initialize(@entries = [] of Entry)
    end

    def accept_children(visitor)
      entries.each do |entry|
        entry.key.accept(visitor)
        entry.value.accept(visitor)
      end
    end

    def_equals_and_hash entries
  end

  # A constant defined by the interpreter. MagicConsts are often used for
  # meta-programming or tooling for libraries to better support end users. All
  # MagicConsts are written in SCREAMING_CASE, and are surrounded by double
  # underscores (`__`).
  #
  #   __FILE__
  # |
  #   __LINE__
  # |
  #   __DIR__
  class MagicConst < Node
    property type : Symbol

    def initialize(@type : Symbol)
    end

    def line
      location.try(&.line) || 0
    end

    def file
      location.try(&.file) || ""
    end

    def dir
      location.try(&.dirname) || ""
    end

    def_equals_and_hash type
  end

  class FunctionCapture < Node
    property value : Node

    def initialize(@value : Node)
    end

    def accept_children(visitor)
      value.accept(visitor)
    end

    def_equals_and_hash value
  end

  # Any node that can appear as-is on the left-hand side of an assignment. This
  # type is only necessary to avoid some type unioning issues with Var, Const,
  # and Underscore throughout the interpreter.
  class StaticAssignable < Node
    property name : String

    def initialize(@name : String)
    end

    def_equals_and_hash name
  end

  # A local variable. Distinct from Calls based on assignments that have been
  # made in the current scope.
  #
  #   [a-z][a-zA-Z0-9_]*
  class Var < StaticAssignable
  end

  # A constant. Distinct from other identifiers by a capital letter as the
  # first character. Constants do not allow re-assignment to their values.
  #
  #   [A-Z][a-zA-Z0-9]*
  class Const < StaticAssignable
  end

  # An underscore-prefixed identifier. Underscores are specifically intended
  # to be used as ignored values (values where an assignment is needed to be
  # semantically correct, but where the value is not used).
  #
  #   _[a-zA-Z0-9]*
  class Underscore < StaticAssignable
    # The name of an underscore is inconsequential. So long as two objects
    # are Underscore nodes, they should be considered equal.
    def_equals_and_hash
  end

  # An instance variable. IVars are primarily used inside of types do define
  # properties that are tied to an instance of an object. The name of an IVar
  # includes the `@` character.
  #
  #   @[a-z][a-zA-Z0-9_]*
  class IVar < Node
    property name : String

    def initialize(@name : String)
    end

    def_equals_and_hash name
  end

  # A value interpolation. Interpolations are used to dynamically insert
  # values in places that normally expect a static value, such as keys in
  # Map literals, or expected values in patterns.
  #
  #   '<' postfix_expression '>'
  #
  # For anything less precedent than a postfix expression (e.g., `a + b`),
  # parentheses can be used around the expression (e.g., `<(a + b)>`).
  class ValueInterpolation < Node
    property value : Node

    def initialize(@value); end

    def accept_children(visitor)
      value.accept(visitor)
    end

    def_equals_and_hash value
  end

  # An explicit reference to self. The primary usecase of `self` is to
  # disambiguate method calls on an object from local variables.
  # Specifically, assignment such as `prop = 2`, where `prop=` is a method
  # on `self` will be parsed as a local variable assignment, whereas
  # `self.prop = 2` will parse as a call to the `prop=` method.
  #
  #   'self'
  class Self < Node
    def_equals_and_hash
  end

  # An assignment. As mentioned for Var, assignments distinguish local
  # variables from Calls. Those local variables are created by these
  # assignments.
  #
  #   target '=' expression
  class SimpleAssign < Node
    property target   : Node
    property value    : Node

    def initialize(@target, @value); end

    def accept_children(visitor)
      target.accept(visitor)
      value.accept(visitor)
    end

    def_equals_and_hash target, value
  end

  # A match assignment. Similar to SimpleAssign, but essentiallly inverted.
  # Match assignments create expectations that the right-hand-side value
  # structurally matches the left-hand-side pattern. The "assignment" portion
  # comes from the ability to name variables on the left-hand-side to capture
  # specific sub-values from the right-hand-side.
  #
  #   pattern '=:' expression
  class MatchAssign < Node
    property pattern  : Node
    property value    : Node

    def initialize(@pattern, @value); end

    def accept_children(visitor)
      pattern.accept(visitor)
      value.accept(visitor)
    end

    def_equals_and_hash pattern, value
  end

  # An operational assignment. These function as a shorthand for an operation
  # followed by an assignment to the same receiver.
  #
  #   target op'=' expression
  #
  # For example, the operator `||` may be used to conditional assign to the
  # target if it is currently falsey. The syntax `target ||= expression` is
  # equivalent to `target = target || expression`. The same applies to other
  # operations: `target += expression` is equivalent to
  # `target = target + value`.
  class OpAssign < Node
    property target   : Node
    property op       : String
    property value    : Node

    def initialize(@target, @op, @value)
    end

    def accept_children(visitor)
      target.accept(visitor)
      value.accept(visitor)
    end

    def_equals_and_hash target, op, value
  end

  # A when expression. These expressions are the fundamental building block
  # for conditional logic (they replace the ubiquitous `if` expressions in
  # most C-based languages). They can also be chained with other `when` or
  # `unless` expressions to create a flat cascade of conditional logic, or an
  # `else` expression to define an alternative if the condition is not met.
  #
  #   'when' condition
  #     body
  #   'end'
  # |
  #   'when' condition
  #     body
  #   'else'
  #     [ alternative ]
  #   'end'
  # |
  #   'when' condition
  #     body
  #   ( when_expression | unless_expression )
  class When < Node
    property condition    : Node
    property body         : Node
    property alternative  : Node

    def initialize(@condition, @body=Nop.new, @alternative=Nop.new)
    end

    def accept_children(visitor)
      condition.accept(visitor)
      body.accept(visitor)
      alternative.accept(visitor)
    end

    def_equals_and_hash condition, body, alternative
  end

  # An unless expression. This is functionally the same as the `when`
  # expression, but evalutes its body when the condition is falsey.
  #
  #   'unless' condition
  #     body
  #   'end'
  # |
  #   'unless' condition
  #     body
  #   'else'
  #     [ alternative ]
  #   'end'
  # |
  #   'unless' condition
  #     body
  #   ( when_expression | unless_expression )
  class Unless < Node
    property condition    : Node
    property body         : Node
    property alternative  : Node

    def initialize(@condition, @body=Nop.new, @alternative=Nop.new)
    end

    def accept_children(visitor)
      condition.accept(visitor)
      body.accept(visitor)
      alternative.accept(visitor)
    end

    def_equals_and_hash condition, body, alternative
  end

  # A while expression. These expressions are the only native looping
  # construct in the language. The body of the expression is executed until
  # the condition evaluates to a falsey value.
  #
  #   'while' condition
  #     body
  #   'end'
  class While < Node
    property condition  : Node
    property body       : Node

    def initialize(@condition, @body=Nop.new)
    end

    def accept_children(visitor)
      condition.accept(visitor)
      body.accept(visitor)
    end

    def_equals_and_hash condition, body
  end

  # An until expression. This is functionally the same as the `while`
  # expression, but executes its body until the condition evaluates to a
  # truthy value.
  #
  #   'until' condition
  #     body
  #   'end'
  class Until < Node
    property condition  : Node
    property body       : Node

    def initialize(@condition, @body=Nop.new)
    end

    def accept_children(visitor)
      condition.accept(visitor)
      body.accept(visitor)
    end

    def_equals_and_hash condition, body
  end

  # A binary operation. This only represents logical operations where the
  # operation is independent of its operands. Non-logical, infix operations
  # such as `a + b` are parsed as Calls.
  abstract class BinaryOp < Node
    property left   : Node
    property right  : Node

    def initialize(@left, @right); end

    def accept_children(visitor)
      left.accept(visitor)
      right.accept(visitor)
    end

    def_equals_and_hash left, right
  end

  # A logical-or expression. Evaluates to a truthy value if either operand
  # is truthy.
  #
  #   expression '||' expression
  class Or < BinaryOp
    def_equals_and_hash
  end

  # A logical-and expression. Evaluates to a truthy value only if both the
  # operands are truthy.
  #
  #   expression '&&' expression
  class And < BinaryOp
    def_equals_and_hash
  end

  # A unary operation. Similar to binary operations, this only represents
  # operations that are independent of the operand. Dependent operations such
  # as the unary `+` are parsed as Calls.
  abstract class UnaryOp < Node
    property value  : Node

    def initialize(@value); end

    def accept_children(visitor)
      value.accept(visitor)
    end

    def_equals_and_hash value
  end

  # A logical-not expression. Evaluates the truthiness of the value and
  # returns the opposite.
  #
  #   '!' postfix_expression
  #
  # For anything less precedent than a postfix expression (e.g., `a + b`),
  # parentheses can be used around the expression (e.g., `!(a + b)`).
  class Not < UnaryOp
  end

  # A negation expression. Mainly applicable for Integers, this node
  # generally indicates an _arithmetic_ negation, as oppposed to a _logical_
  # negation as indicated by a `!`.
  #
  #   '-' postfix_expression
  class Negation < UnaryOp
  end

  # A splat expression. Splats deconstruct collections to be treated as
  # multiple individual values. Splats can also indicate the opposite: that a
  # single collection should be created from multiple values.
  #
  #   '*' name
  class Splat < UnaryOp
  end

  # A method call. Calls are the building block of functionality. Any
  # operation not expressed by a distinct node is considered a Call. For
  # example, `a + b` is a call to the method `+` on `a` with `b` as an
  # argument, `obj.member` is a call to the method `member` on `obj`, etc.
  # Additionally, any identifier that is not known to be a local variable
  # (created by a SimpleAssign or MatchAssign) is considered a Call.
  #
  #   [ receiver '.' ] name [ block ]
  # |
  #   [ receiver '.' ] name '(' [ arg [ ',' arg ]* ] ')' [ block ]
  # |
  #   expression '(' [ arg [ ',' arg ]* ] ')' [ block ]
  # |
  #   arg operator arg
  #
  # Any expression can be forced into a Call by adding parentheses as a
  # suffix. Complex expressions will require parentheses around the expression
  # to avoid ambiguity. This is the third form shown above.
  #
  # The last form is for infix operations, such as `a + b` shown above, where
  # `operator` would be the `+`.
  class Call < Node
    property! receiver    : Node?
    property  name        : String | Node
    property  args        : Array(Node)
    property! block       : (Block | FunctionCapture)?
    property? infix       : Bool

    def initialize(@receiver, @name, @args = [] of Node, @block=nil, @infix=false)
    end

    def accept_children(visitor)
      receiver?.try(&.accept(visitor))
      if name_node = name.as?(Node)
        name_node.accept(visitor)
      end
      args.each(&.accept(visitor))
      block?.try(&.accept(visitor))
    end

    def_equals_and_hash name, receiver?, args, block?, infix?
  end

  # A parameter for a method definition. Parameters can take many forms. The
  # simplest parameter is just a name or a pattern. If the parameter is a
  # name, it may be prefixed by a '*' to indicate a splat argument, or a '&'
  # to indicate a block argument.
  #
  # Additionally, if the parameter is a name, it may be prefixed with a
  # pattern and a match operator, or suffixed with a type restriction and/or
  # guard clause, as shown in the final form.
  #
  #   pattern
  # |
  #   '*' name
  # |
  #   '&' name
  # |
  #   [ pattern '=:' ] name [ ':' const ] [ '|' guard ]
  class Param < Node
    property! pattern     : Node?
    property! name        : String?
    property! restriction : Const?
    property! guard       : Node?
    property? splat       : Bool
    property? block       : Bool

    def initialize(@pattern=nil, @name=nil, @restriction=nil, @guard=nil, @splat=false, @block=false)
    end

    def accept_children(visitor)
      pattern?.try(&.accept(visitor))
      restriction?.try(&.accept(visitor))
      guard?.try(&.accept(visitor))
    end

    def_equals_and_hash pattern?, name?, restriction?, guard?, splat?, block?
  end

  # A method definition. Parameters for methods must be wrapped in
  # parentheses. If the method does not accept parameters, the parentheses
  # may be omitted. In the context of a type definition, methods can also be
  # defined as "static" - or related to the type, rather than instances of the
  # type - using the alternate keyword `defstatic`.
  #
  #   [ 'def' | 'defstatic' ] name '(' [ param [ ',' param ]* ] ')'
  #     body
  #   'end'
  # |
  #   [ 'def' | 'defstatic' ] name
  #     body
  #   'end'
  class Def < Node
    property  name          : String
    property  params        : Array(Param)
    property! block_param   : Param?
    property  body          : Node
    property! splat_index   : Int32?
    property? static        : Bool

    def initialize(@name, @params = [] of Param, @body=Nop.new, @block_param=nil, @splat_index=nil, @static=false)
    end

    def accept_children(visitor)
      params.each(&.accept(visitor))
      block_param?.try(&.accept(visitor))
      body.accept(visitor)
    end

    def_equals_and_hash name, params, block_param?, body, splat_index?, static?
  end

  # A block definition. Functionally, a block is equivalent to a method
  # definition. The only difference being that a block is always unnamed.
  # Syntax-wise, blocks appear as the last expression in a Call, and can be
  # created either by a `do...end` construct or curly braces (`{ ... }`).
  #
  #   'do' [ '|' param [ ',' param ]* '|' ]
  #     body
  #   'end'
  # |
  #   '{' [ '|' param [ ',' param ]* '|' ] body '}'
  #
  # Convention recommends that the brace form only be used for single-line
  # blocks, and the `do...end` form only be used for multi-line blocks.
  class Block < Def
    # Style should be `:doend` or `:brace`, respectively, based on the bracing
    # style used, as shown above.
    property  style  : Symbol

    def initialize(@params = [] of Param, @body=Nop.new, @block_param=nil, @splat_index=nil, @style=:brace)
      @name = ""
      @static = false
    end

    def_equals_and_hash
  end

  # A shorthand function definition with multiple clauses. AnonymousFunctions
  # are most commonly used to define complex behavior in place of a block
  # parameter for a function. Clauses are defined using a "stab" (`->`),
  # followed by a parenthesized parameter list, then a clause body wrapped like
  # a normal block (either with `{...}` or `do...end`).
  #
  # An anonymous function must be given at least one clause to be valid.
  #
  #   'fn'
  #     [
  #       '->' '(' [ param [ ',' param ]* ]? ')' [ '{' | 'do' ]
  #         body
  #       [ '}' | 'end' ]
  #     ]+
  #   'end'
  class AnonymousFunction < Node
    property clauses : Array(Block)
    # `internal_name` is used as the name of the function for use in stack
    # traces and other reporting mechanisms. This should not be used for any
    # other public functionality.
    property internal_name : String

    def initialize(@clauses = [] of Block, @internal_name : String = "anonymous function")
    end

    def accept_children(visitor)
      clauses.each(&.accept(visitor))
    end

    def_equals_and_hash clauses
  end

  # A match expression. Match expressions are a syntax sugar representing an
  # anonymous function definition and immediate invocation with the
  # arguments.
  #
  # A match expression must be given at least one argument and one clause to
  # be considered valid.
  #
  #   'match' [ argument [ ',' argument ]* ]
  #     [
  #       '->' '(' [ param [ ',' param ]* ]? ')' [ '{' | 'do' ]
  #         body
  #       [ '}' | 'end' ]
  #     ]+
  #   'end'
  class Match < Node
    property arguments : Array(Node) = [] of Node
    property clauses : Array(Block)

    def initialize(@arguments = [] of Node, @clauses = [] of Block)
    end

    def accept_children(visitor)
      arguments.each(&.accept(visitor))
      clauses.each(&.accept(visitor))
    end

    def_equals_and_hash arguments, clauses
  end

  # A module definition. The name of the module must be a Constant (i.e., it
  # must start with a capital letter).
  #
  #   'defmodule' const
  #     body
  #   'end'
  class ModuleDef < Node
    property name : String
    property body : Node

    def initialize(@name, @body=Nop.new)
    end

    def accept_children(visitor)
      body.accept(visitor)
    end

    def_equals_and_hash name, body
  end

  # A type definition. TypeDefs are similar to ModuleDefs, but define a data
  # type that can be instantiated similar to how Literals create primitives.
  #
  #   'deftype' const : const
  #     body
  #   'end'
  class TypeDef < Node
    property  name       : String
    property  body       : Node
    property! supertype  : Call | Const | ValueInterpolation | Nil

    def initialize(@name, @body=Nop.new, @supertype=nil)
    end

    def accept_children(visitor)
      body.accept(visitor)
    end

    def_equals_and_hash name, body
  end

  # An instantiation of a type. Instantiations create new instances of the
  # specified type. After creating the value for the new type, a callback on
  # the instance will be called to initialize the properties of the instance.
  #
  #   '%' [ const | interpolation ] '{' [ arg [ ',' arg ]* ] '}' [ block ]
  class Instantiation < Node
    property  type    : Node
    property  args    : Array(Node)
    property! block   : (Block | FunctionCapture)?

    def initialize(@type, @args=[] of Node, @block=nil)
    end

    def accept_children(visitor)
      type.accept(visitor)
      args.each(&.accept(visitor))
      block?.try(&.accept(visitor))
    end

    def_equals_and_hash type, args, block?
  end

  # A require expression. Requires are the primary mechanism for loading code
  # from other source files. Files will only be loaded once. If another
  # require appears that references the same file, it will not be loaded
  # again. The result of a require statement will be a boolean indicating
  # whether the code was loaded.
  #
  #   'require' string
  class Require < Node
    property path : Node

    def initialize(@path : Node); end

    def accept_children(visitor)
      path.accept(visitor)
    end

    def_equals_and_hash path
  end

  # An include expression. Includes are the primary mechanism for composing
  # modules. When an Include is encountered, the module referenced by the
  # path must already exist.
  #
  #   'include' path
  class Include < Node
    property path : Node

    def initialize(@path : Node); end

    def accept_children(visitor)
      path.accept(visitor)
    end

    def_equals_and_hash path
  end

  # An extend expression. Extends allow Type instances to inherit
  # static methods and properties from Modules. When an Extend is
  # encountered, the module referenced by the path must already exist.
  #
  #   'extend' path
  class Extend < Node
    property path : Node

    def initialize(@path : Node); end

    def accept_children(visitor)
      path.accept(visitor)
    end

    def_equals_and_hash path
  end

  # Any flow control expression. These represent expressions that usurp the
  # normal flow of execution. A flow control expression may optionally carry
  # a value to be returned at the destination.
  class ControlExpr < Node
    property! value : Node?

    def initialize(@value=nil); end

    def accept_children(visitor)
      value?.try(&.accept(visitor))
    end

    def_equals_and_hash value?
  end

  # A return expression. Return expressions are used to prematurely exit a
  # method
  #
  #   'return' [ value ]
  class Return < ControlExpr
    def_equals_and_hash
  end

  # A next expression. Next expressions are semantically equivalent to Return
  # expressions, and are meant to be used as an alternative inside of Blocks
  # to avoid confusion around what is returning and to where.
  #
  #   'next' [ value ]
  class Next < ControlExpr
    def_equals_and_hash
  end

  # A break expression. Break expressions are similar to Return expressions,
  # except they cause they also cause the _caller_ to return. The primary use
  # for a break expression is to end iteration of a collection early.
  #
  #   'break' [ value ]
  class Break < ControlExpr
    def_equals_and_hash
  end

  # A raise expression. Raise expressions create an Exception and cause the
  # interpreter to immediately start backtracking up the callstack until a node
  # capable of handling the Exception is encountered (i.e., has an attached
  # `rescue` clause).
  #
  #   'raise' value
  class Raise < ControlExpr
    def_equals_and_hash
  end

  # A rescue expression. Rescues are used to capture Exceptions created with
  # `raise`. Rescues may also provide a parameter (with all the same syntax as
  # parameters used in Defs) to restrict what Exceptions can be handled by the
  # expression.
  #
  #   'rescue' [ param [ ':' type_restriction ] ]
  #     body
  class Rescue < Node
    property! param : Param?
    property  body  : Node

    def initialize(@body : Node=Nop.new, @param : Param? = nil)
    end

    def accept_children(visitor)
      param?.try(&.accept(visitor))
      body.accept(visitor)
    end

    def_equals_and_hash param?, body
  end

  # A set of Expressions representing semantics for handling exceptions.
  # Whenever a `rescue` or `ensure` is encountered at the end of a Def, Block,
  # or Begin, the existing node is wrapped in an ExceptionHandler, and the
  # handling blocks are parsed into this node.
  #
  #   body
  #   [ rescue_expression ]*
  #   [ else_expression ]
  #   [ ensure_expression ]
  class ExceptionHandler < Node
    property  body     : Node
    property  rescues  : Array(Rescue)
    property! else     : Node?
    property! ensure   : Node?

    def initialize(@body : Node, @rescues=[] of Rescue, @else : Node?=nil, @ensure : Node?=nil)
    end

    def location
      @body.location
    end

    def end_location
      case
      when ensure?
        self.ensure.end_location
      when rescues.size > 0
        self.rescues.last.end_location
      else
        body.end_location
      end
    end

    def accept_children(visitor)
      body.accept(visitor)
      rescues.each(&.accept(visitor))
      @else.try(&.accept(visitor))
      @ensure.try(&.accept(visitor))
    end

    def_equals_and_hash body, rescues, else?, ensure?
  end

  # A full documentation comment. Documentation comments are distinct
  # entities that can attach to other objects via a `reference`. References
  # are evaluated based on the current lexical context
  #
  #   '#doc' reference [ '->' reference ]
  #   [ '#|' content ]*
  class DocComment < Node
    property reference  : DocReference
    property returns    : String?
    property content    : String?

    def initialize(@reference : DocReference, @returns : String?, @content : String?)
    end

    def_equals_and_hash reference, returns, content
  end

  # A reference expression. References are the standard way of referring to
  # an object in Myst code. Any normal identifier is a valid reference.
  # Static references are written with the `.` notation (e.g., `File.open` or
  # `IO.FileDescriptor`). Instance references are written using the `#`
  # notation (e.g., `List#each`). References can also be nested recursively
  # (e.g., `Assert.Assertion#is_truthy`).
  #
  #   reference '.' identifier
  # |
  #   reference '#' identifier
  # |
  #   identifier
  class DocReference < Node
    enum Style
      # A static reference, normally represented using `.`. For example,
      # `File.open` or `IO.FileDescriptor`.
      STATIC
      # An instance reference, normally represented using `#`. For example,
      # `List#each` or `Assertion#is_truthy`.
      INSTANCE
    end

    property receiver : DocReference?
    property style    : Style
    property value    : String

    def initialize(@receiver : DocReference?, @style : Style, @value : String)
    end

    def_equals_and_hash receiver, style, value
  end
end
