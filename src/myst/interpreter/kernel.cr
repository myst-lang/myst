module Myst::Kernel
  extend self

  SCOPE = Scope.new

  PRIMITIVE_APIS = {} of ::String => Scope

  macro add_kernel_method(name, arity)
    SCOPE["{{name.id}}"] = TNativeFunctor.new("{{name.id}}", {{arity}}) do |args|
      {{ yield }}
    end
  end

  macro register_primitive_api(module_def)
    PRIMITIVE_APIS["{{module_def.id}}"] = {{module_def}}::METHODS
  end
end

require "./kernel/primitive_api"
require "./kernel/*"
