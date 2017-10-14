module Myst
  class Interpreter
    def visit(node : TypeDef)
      # If a type with the same name already exists in the current scope,
      # use it. Otherwise, create a new type in the current scope.
      if @symbol_table.has_key?(node.name)
        type = @symbol_table[node.name].as(TType)
      else
        type = TType.new(node.name, current_scope)
        @symbol_table.assign(node.name, type)
      end

      push_scope(type.instance_scope)
      visit_type_def_body(node.body, type)
      pop_scope

      @stack.push(type)
    end

    # This is mostly the same as `visit(node : Expressions)`, but with a
    # special case for `Def`, where static definitions are placed in a separate
    # scope
    private def visit_type_def_body(node : Expressions, type : TType)
      node.children.each do |expr|
        if expr.is_a?(Def)
          push_scope(type.scope) if expr.static?
          visit(expr)
          pop_scope if expr.static?
        else
          visit(expr)
        end

        @stack.pop
      end
    end

    private def visit_type_def_body(node : Nop, type : TType)
      # Nothing happens for Nop.
    end

    private def visit_type_def_body(node : Node, type : TType)
      raise "Compiler bug! Attempting to visit #{node.class} as the body of a TypeDef."
    end
  end
end
