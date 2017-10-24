module Myst
  class Interpreter
    def create_kernel : TModule
      kernel = TModule.new("Kernel")
      kernel.scope.clear
      kernel.scope["Nil"]     = init_nil
      kernel.scope["Boolean"] = init_boolean
      kernel.scope["Integer"] = init_integer
      kernel.scope["Float"]   = init_float
      kernel.scope["String"]  = init_string
      kernel.scope["Symbol"]  = init_symbol
      kernel.scope["List"]    = init_list
      kernel.scope["Map"]     = init_map
      kernel.scope["IO"]      = init_io
      # kernel.scope["Functor"]     = FUNCTOR_TYPE
      # kernel.scope["FunctorDef"]  = FUNCTOR_DEF_TYPE
      # kernel.scope["NativeDef"]   = NATIVE_DEF_TYPE
      # kernel.scope["Module"]      = MODULE_TYPE
      # kernel.scope["Type"]        = TYPE_TYPE
      kernel
    end
  end
end
