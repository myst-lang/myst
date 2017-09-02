module Myst
  module AST
    class Node
      property type_name : String?

      def accept(visitor)
        visitor.visit(self)
      end

      @[AlwaysInline]
      def children
        vars = {{ @type.instance_vars }}
        node_vars = [] of AST::Node
        vars.each do |node|
          if node.is_a? AST::Node
            node_vars << node
          end
        end
        node_vars
      end

      def type_name : String
        @type_name ||= {{@type.name}}.name.split("::").last
      end
    end


    macro ast_node(name, *properties)
      class {{name.id}} < Node
        {% for prop in properties %}
          property {{prop.var}} : {{prop.type}}
        {% end %}

        def initialize({{ *properties.map{ |p| "@#{p.var}".id } }})
        end
      end
    end


    ast_node Empty


    # Lists

    ast_node Block,
      children  : Array(Node)

    ast_node ExpressionList,
      children  : Array(Node)



    # Statements

    ast_node FunctionDefinition,
      name        : String,
      parameters  : Array(Pattern),
      body        : Block

    ast_node ModuleDefinition,
      name        : String,
      body        : Block

    ast_node RequireStatement,
      path        : Node,
      working_dir : String

    ast_node IncludeStatement,
      path        : Node



    # Expressions

    # Patterns are complex, so currently they are defined outside the macro for
    # flexibility and brevity. Properties of this class correspond to their
    # syntax like so:
    #
    #     pattern =: name : type | guard
    #
    # Currently, only `pattern` and `name` are supported. `name` may also be
    # prefixed with an asterisk to indicate the splat collector, or an
    # ampersand to indicate a block parameter. Block parameters are only valid
    # in function parameter definitions.
    class Pattern
      property! pattern : Node?
      property! name : Ident?
      property! type_restriction : Const?
      # True if this parameter should be used as the splat collector. Denoted
      # in the syntax by a preceding asterisk, e.g. `*args`.
      property? splat : Bool
      # True if this parameter should be used as the block parameter. Denoted
      # in the syntax by a preceding ampersand, e.g., `&block`.
      property? block : Bool

      def initialize(
        @pattern = nil,
        @name = nil,
        @type_restriction = nil,
        @splat = false,
        @block = false
      ); end
    end

    ast_node SimpleAssignment,
      target    : Node,
      value     : Node

    ast_node PatternMatchingAssignment,
      pattern   : Node,
      value     : Node

    ast_node WhenExpression,
      condition   : Node,
      body        : Block,
      alternative : Node?

    ast_node UnlessExpression,
      condition   : Node,
      body        : Block,
      alternative : Node?

    ast_node ElseExpression,
      body        : Block

    ast_node WhileExpression,
      condition   : Node,
      body        : Block

    ast_node UntilExpression,
      condition   : Node,
      body        : Block

    ast_node LogicalExpression,
      operator  : Token,
      left      : Node,
      right     : Node

    ast_node EqualityExpression,
      operator  : Token,
      left      : Node,
      right     : Node

    ast_node RelationalExpression,
      operator  : Token,
      left      : Node,
      right     : Node

    ast_node BinaryExpression,
      operator  : Token,
      left      : Node,
      right     : Node

    ast_node UnaryExpression,
      operator  : Token,
      operand   : Node

    ast_node FunctionCall,
      receiver  : Node,
      arguments : ExpressionList,
      block     : FunctionDefinition?

    ast_node MemberAccessExpression,
      receiver  : Node,
      member    : String

    ast_node MemberAssignmentExpression,
      receiver  : Node,
      member    : String,
      value     : Node

    ast_node AccessExpression,
      target  : Node,
      key     : Node

    ast_node AccessSetExpression,
      target  : Node,
      key     : Node,
      value   : Node

    ast_node MapEntryDefinition,
      key     : Node,
      value   : Node

    ast_node ValueInterpolation,
      value   : Node



    # Literals

    ast_node Ident,
      name      : String

    ast_node Const,
      name      : String


    ast_node IntegerLiteral,
      value     : String

    ast_node FloatLiteral,
      value     : String

    ast_node StringLiteral,
      value     : String

    ast_node SymbolLiteral,
      value     : String

    ast_node BooleanLiteral,
      value     : Bool


    ast_node ListLiteral,
      elements  : ExpressionList

    ast_node MapLiteral,
      elements  : ExpressionList
  end
end
