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


    # Expressions

    ast_node SimpleAssignment,
      target    : Node,
      value     : Node

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


    # Literals

    ast_node VariableReference,
      name      : String

    ast_node IntegerLiteral,
      value     : String

    ast_node FloatLiteral,
      value     : String

    ast_node StringLiteral,
      value     : String

    ast_node BooleanLiteral,
      value     : Bool
  end
end
