require "./visitor"

module Myst
  module AST
    class Node
      property type_name : String?

      def accept(visitor : Visitor, io : IO)
        visitor.visit(self, io)
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

    ast_node ParameterList,
      children  : Array(FunctionParameter)



    # Statements

    ast_node FunctionDefinition,
      name        : String,
      parameters  : ParameterList,
      body        : Block

    ast_node ModuleDefinition,
      name        : String,
      body        : Block

    ast_node RequireStatement,
      path        : Node,
      working_dir : String



    # Expressions

    ast_node FunctionParameter,
      name      : String

    ast_node SimpleAssignment,
      target    : Node,
      value     : Node

    ast_node PatternMatchingAssignment,
      pattern   : Node,
      value     : Node

    ast_node IfExpression,
      condition   : Node,
      body        : Block,
      alternative : Node?

    ast_node UnlessExpression,
      condition   : Node,
      body        : Block,
      alternative : Node?

    ast_node ElifExpression,
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

    ast_node VariableReference,
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
