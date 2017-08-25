module Myst
  module PrimitiveAPI
    macro included
      METHODS = Scope.new
    end

    macro primitive_func(type, name, arity)
      METHODS["{{name.id}}"] = TNativeFunctor.new("{{name.id}}", {{arity+1}}) do |args, block, interpreter|
        this = args.shift
        next TNil.new unless this.is_a?({{type}})
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
