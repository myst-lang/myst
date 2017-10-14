module Myst
  class Interpreter
    def visit(node : Instantiation)
      visit(node.type)
      type = stack.pop

      unless type.is_a?(TType)
        raise "#{type} is not an instantiable type (not a TType)."
      end

      instance = TInstance.new(type)
      # Allow access to the type from the instance through `.type`.
      instance.scope["type"] = type

      stack.push(instance)

      # TODO: Add callback for initializing the new instance.
      # args = node.args.map{ |a| a.accept(self); stack.pop }

      # if node.block?
      #   node.block.accept(self)
      #   block = stack.pop.as(TFunctor)
      # end

      # result = Invocation.new(self, func, receiver, args, block).invoke
      # stack.push(result)
    end
  end
end
