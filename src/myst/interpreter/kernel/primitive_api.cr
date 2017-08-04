module Myst
  module PrimitiveAPI
    macro included
      METHODS = Scope.new
    end

    macro primitive_func(type, name, arity)
      METHODS["{{name.id}}"] = TNativeFunctor.new("{{name.id}}", {{arity+1}}) do |args|
        this = args.shift
        next TNil.new unless this.is_a?({{type}})
        {{ yield }}
      end
    end
  end
end
