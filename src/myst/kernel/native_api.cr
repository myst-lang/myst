module Myst
  module NativeAPI
    macro included
      METHODS = Scope.new
    end

    macro native_func(name, arity)
      METHODS["{{name.id}}"] = TNativeFunctor.new("{{name.id}}", {{arity}}) do |args, block, interpreter|
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

      args = Interpreter::Args.new({{args.size}}.times.map{ interpreter.stack.pop }.to_a)
      Interpreter::Call.new(block, args, interpreter).run
    end
  end
end
