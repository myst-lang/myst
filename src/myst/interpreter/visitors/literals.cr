class Myst::Interpreter
  def visit(node : AST::IntegerLiteral | AST::FloatLiteral | AST::StringLiteral | AST::SymbolLiteral | AST::BooleanLiteral)
    stack.push(Value.from_literal(node))
  end

  def visit(node : AST::NilLiteral)
    stack.push(TNil.new)
  end


  def visit(node : AST::ListLiteral)
    recurse(node.elements)
    elements = node.elements.children.map{ |el| stack.pop }
    stack.push(TList.new(elements.reverse))
  end


  def visit(node : AST::MapLiteral)
    # The elements should push value pairs onto the stack:
    # STACK
    # | value2
    # | key2
    # | value1
    # V key1
    recurse(node.elements)
    map_entries = node.elements.children.map do |el|
      value, key = stack.pop, stack.pop
      {key, value}
    end

    map = TMap.new
    map_entries.reverse_each do |key, value|
      map.assign(key, value)
    end
    stack.push(map)
  end

  def visit(node : AST::MapEntryDefinition)
    recurse(node.key)
    recurse(node.value)
  end

  def visit(node : AST::ValueInterpolation)
    recurse(node.value)
  end
end
