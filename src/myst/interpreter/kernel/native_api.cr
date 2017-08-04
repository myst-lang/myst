module Myst
  module NativeAPI
    macro included
      METHODS = Scope.new
    end

    macro native_func(name, arity)
      METHODS["{{name.id}}"] = TNativeFunctor.new("{{name.id}}", {{arity}}) do |args|
        {{ yield }}
      end
    end
  end
end
