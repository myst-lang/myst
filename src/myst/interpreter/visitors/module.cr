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
    @symbol_table.pop_scope
    stack.push(_module)
  end
end
