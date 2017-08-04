module Myst
  module NativeAPI
    macro included
      METHODS = Scope.new
    end

    macro native_func(name, arity)
      METHODS["{{name.id}}"] = TNativeFunctor.new("{{name.id}}", {{arity}}) do |args, block, interpreter, io|
        {{ yield }}
      end
    end

    macro expect_block_arg(block="block")
      next TNil.new unless block
    end

    macro yield_to_block(*args)
      {% for arg in args %}
        interpreter.stack.push({{arg}})
      {% end %}

      block.parameters.children.reverse_each do |param|
        interpreter.symbol_table.assign(param.name, interpreter.stack.pop(), make_new: true)
      end

      block.accept(interpreter, io)
    end
  end
end
