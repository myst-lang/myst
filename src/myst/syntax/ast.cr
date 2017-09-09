module Myst
  module AST
    abstract class Node
      property location : Location?
      property end_location : Location?

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


    # The `nil` literal.
    #
    #   'nil'
    class NilLiteral < Node
      def_equals_and_hash
    end

    # A boolean literal.
    #
    #   'true' | 'false'
    class BooleanLiteral < Node
      property value : Bool

      def initialize(@value); end

      def_equals_and_hash value
    end

    # Any integer literal. Underscores from the literal are removed from the
    # value stored by this node.
    #
    #   [0-9][_0-9]*
    class IntegerLiteral < Node
      property value : String

      def initialize(@value); end

      def_equals_and_hash value
    end

    # A float literal. Same as above, but for values including decimals. Float
    # literals _must_ have a decimal value both before _and_ after the radix.
    #
    #   [0-9][_0-9]*\.[_0-9]+
    class FloatLiteral < Node
      property value : String

      def initialize(@value); end

      def_equals_and_hash value
    end

    # A string literal. Any value wrapped in double quotes. Characters
    # immediately following a backslash are escaped.
    #
    #   '"' \w* '"'
    class StringLiteral < Node
      property value : String

      def initialize(@value); end

      def_equals_and_hash value
    end

    # A symbol literal. The value stored by this node does not include the
    # designating colon.
    #
    #   ':' name
    # |
    #   name ':'
    #
    # The second form only applies in some contexts (map entries, etc.).
    class SymbolLiteral < Node
      property value : String

      def initialize(@value); end

      def_equals_and_hash value
    end

    # A List literal. Lists are always delimited by square braces, and may
    # contain any number of elements, delimited from each other by commas.
    #
    #   '[' [ expression [ ',' expression ]* ] ']'
    class ListLiteral < Node
      property elements : Array(Node)

      def initialize(@elements = [] of Node)
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
    #   interpolation : expression
    class MapLiteral < Node
      property elements : Array(Entry)

      record Entry,
        key : Node,
        value : Node

      def initialize(@elements = [] of Entry)
      end

      def accept_children(visitor)
        elements.each do |entry|
          entry.key.accept(visitor)
          entry.value.accept(visitor)
        end
      end

      def_equals_and_hash elements
    end

    # A local variable. Distinct from Calls based on assignments that have been
    # made in the current scope.
    #
    #   [a-z][a-zA-Z0-9_]*
    class Var < Node
      property name : String

      def initialize(@name : String)
      end

      def_equals_and_hash name
    end

    # A constant. Distinct from other identifiers by a capital letter as the
    # first character. Constants do not allow re-assignment to their values.
    #
    #   [A-Z][a-zA-Z0-9]*
    class Const < Node
      property name : String

      def initialize(@name : String)
      end

      def_equals_and_hash name
    end

    # An underscore-prefixed identifier. Underscores are specifically intended
    # to be used as ignored values (values where an assignment is needed to be
    # semantically correct, but where the value is not used).
    #
    #   _[a-zA-Z0-9]*
    class Underscore < Node
      property name : String

      def initialize(@name : String)
      end

      # The name of an underscore is inconsequential. So long as two objects
      # are Underscore nodes, they should be considered equal.
      def_equals_and_hash
    end

    # A concatenated series of constants. Each entry in the path sets the scope
    # for lookup of the next entry.
    #
    #   const [ '.' const ]*
    class Path < Node
      property names : Array(String)

      def initialize(@names = [] of String)
      end

      def initialize(*names)
        @names = names.to_a
      end

      def_equals_and_hash names
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
      def_equals_and_hash
    end

    # A splat expression. Splats deconstruct collections to be treated as
    # multiple individual values. Splats can also indicate the opposite: that a
    # single collection should be created from multiple values.
    #
    #   '*' name
    class Splat < UnaryOp
      def_equals_and_hash
    end

    # A method call. Calls are the building block of functionality. Any
    # operation not expressed by a distinct node is considered a call. For
    # example, `a + b` is a call to the method `+` on `a` with `b` as an
    # argument, `obj.member` is a call to the method `member` on `obj`, etc.
    # Additionally, any identifier that is not known to be a local variable
    # (created by a SimpleAssign or MatchAssign) is considered a Call.
    #
    #   [ receiver '.' ] name [ block ]
    # |
    #   [ receiver '.' ] name '(' [ arg [ ',' arg ]* ] ')' [ block ]
    # |
    #   arg operator arg
    #
    # The last form is for infix operations, such as `a + b` shown above, where
    # `operator` would be the `+`.
    class Call < Node
      property! receiver  : Node?
      property  name      : String
      property  args      : Array(Node)
      property  block     : Block?

      def initialize(@receiver, @name, @args = [] of Node, @block=nil)
      end

      def accept_children(visitor)
        receiver.try(&.accept(visitor))
        args.each(&.accept(visitor))
        block.try(&.accept(visitor))
      end

      def_equals_and_hash receiver, name, args, block
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

      def initialize(@pattern=nil, @name=nil, @restriction=nil, @guard=nil)
      end

      def accept_children(visitor)
        pattern.try(&.accept(visitor))
        restriction.try(&.accept(visitor))
        guard.try(&.accept(visitor))
      end

      def_equals_and_hash pattern, name, restriction, guard
    end

    # A method definition. Parameters for methods must be wrapped in
    # parentheses. If the method does not accept parameters, the parentheses
    # may be omitted.
    #
    #   'def' name '(' [ param [ ',' param ]* ] ')'
    #     body
    #   'end'
    # |
    #   'def' name
    #     body
    #   'end'
    class Def < Node
      property name         : String
      property params       : Array(Param)
      property block_param  : Param?
      property body         : Node
      property splat_index  : Int32?

      def initialize(@name, @params = [] of Param, @body=Nop.new, @block_param=nil, @splat_index=nil)
      end

      def accept_children(visitor)
        params.each(&.accept(visitor))
        block_param.try(&.accept(visitor))
        body.accept(visitor)
      end

      def_equals_and_hash name, params, block_param, body, splat_index
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
      def_equals_and_hash
    end

    # A module definition. The name of the module must be a Constant (i.e., it
    # must start with a capital letter). Not only is this good practice in
    # general, but it also makes parsing Paths simpler and more efficient.
    #
    #   'module' const
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

    # A require expression. Requires are the primary mechanism for loading code
    # from other source files. Files will only be loaded once. If another
    # require appears that references the same file, it will not be loaded
    # again. The result of a require statement will be a boolean indicating
    # whether the code was loaded.
    #
    #   'require' string
    class Require < Node
      property path : String

      def initialize(@path : String); end

      def_equals_and_hash path
    end

    # An include expression. Includes are the primary mechanism for composing
    # modules. When an Include is encountered, the module referenced by the
    # path must already exist. The path can be any valid Path expression, such
    # as `TopLevelModule` or `Some.Nested.Module`.
    #
    #   'include' path
    class Include < Node
      property path : Path

      def initialize(@path : Path); end

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
        value.try(&.accept(visitor))
      end

      def_equals_and_hash value
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
  end
end
