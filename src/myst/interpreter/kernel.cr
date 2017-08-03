module Myst::Kernel
  extend self

  SCOPE = Scope.new

  macro add_kernel_method(name, arity)
    SCOPE["{{name.id}}"] = TNativeFunctor.new("{{name.id}}", {{arity}}) do |args|
      {{ yield }}
    end
  end
end

require "./kernel/*"
