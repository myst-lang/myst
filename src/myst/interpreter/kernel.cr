module Myst::Kernel
  extend self

  SCOPE = Scope.new

  macro add_kernel_method(name, arity)
    SCOPE["{{name.id}}"] = TNativeFunctor.new("{{name.id}}", {{arity}}, ->Kernel.{{name.id}}(Array(Value)))
  end
end

require "./kernel/*"
