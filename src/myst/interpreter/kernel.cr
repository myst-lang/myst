module Myst
  class Interpreter
    def create_kernel : TModule
      kernel = TModule.new("Kernel")
      kernel.scope.clear
      root_scope = kernel.scope
      kernel.scope["Nil"]       = init_nil(root_scope)
      kernel.scope["Boolean"]   = init_boolean(root_scope)
      kernel.scope["Integer"]   = init_integer(root_scope)
      kernel.scope["Float"]     = init_float(root_scope)
      kernel.scope["String"]    = init_string(root_scope)
      kernel.scope["Symbol"]    = init_symbol(root_scope)
      kernel.scope["List"]      = init_list(root_scope)
      kernel.scope["Map"]       = init_map(root_scope)
      kernel.scope["IO"]        = init_io(root_scope)
      kernel.scope["FSUtils"]   = init_file_utils(root_scope)
      # kernel.scope["Functor"]     = FUNCTOR_TYPE
      # kernel.scope["FunctorDef"]  = FUNCTOR_DEF_TYPE
      # kernel.scope["NativeDef"]   = NATIVE_DEF_TYPE
      # kernel.scope["Module"]      = MODULE_TYPE
      # kernel.scope["Type"]        = TYPE_TYPE
      kernel
    end
  end
end
