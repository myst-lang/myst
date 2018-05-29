module Myst
  class Interpreter
    def create_kernel : TModule
      @kernel.scope.clear
      init_top_level
      @kernel.scope["Kernel"]     = @kernel
      @kernel.scope["Type"]       = @base_type
      @kernel.scope["Nil"]        = init_nil
      @kernel.scope["Boolean"]    = init_boolean
      @kernel.scope["Integer"]    = init_integer
      @kernel.scope["Float"]      = init_float
      @kernel.scope["String"]     = init_string
      @kernel.scope["Symbol"]     = init_symbol
      @kernel.scope["List"]       = init_list
      @kernel.scope["Map"]        = init_map
      @kernel.scope["Functor"]    = init_functor
      io_type = init_io
      @kernel.scope["IO"]         = io_type
      @kernel.scope["TCPSocket"]  = init_tcp_socket(io_type)
      @kernel.scope["Time"]       = init_time
      @kernel.scope["Random"]     = init_random
      @kernel.scope["ENV"]        = init_env
      @kernel
    end
  end
end
