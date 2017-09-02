class Myst::Interpreter
  def visit(node : AST::ModuleDefinition)
    _module = begin
      if @symbol_table[node.name]?
        @symbol_table[node.name]
      else
        @symbol_table[node.name] = TObject.new
      end
    end
    @symbol_table.push_scope(_module.as(Scope))
    recurse(node.body)
    # Blocks preserve the value of their last expression to support implicit
    # return values. However, a module returns itself, not the last thing it
    # defined, so that last expression must be popped.
    stack.pop
    @symbol_table.pop_scope
    stack.push(_module)
  end
end
