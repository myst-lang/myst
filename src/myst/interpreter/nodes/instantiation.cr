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

      # If the instance has an `initialize` method, call it with the arguments
      # given to the Instantiation.
      if (initializer = instance.scope["initialize"]?) && initializer.is_a?(TFunctor)
        args = node.args.map{ |a| a.accept(self); stack.pop }
        if node.block?
          node.block.accept(self)
          block = stack.pop.as(TFunctor)
        end

        Invocation.new(self, initializer, instance, args, block).invoke
      end

      stack.push(instance)
    end
  end
end
