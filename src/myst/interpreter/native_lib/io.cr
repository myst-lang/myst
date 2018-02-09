module Myst
  class Interpreter
    NativeLib.method :io_read, Value, size : TInteger do
      __raise_runtime_error("`IO#read` must be implemented by inheriting types.")
    end

    NativeLib.method :io_write, Value, content : Value do
      __raise_runtime_error("`IO#write` must be implemented by inheriting types.")
    end

    def init_io(kernel : TModule)
      io_type = TType.new("IO", kernel.scope)

      NativeLib.def_instance_method(io_type, :read,   :io_read)
      NativeLib.def_instance_method(io_type, :write,  :io_write)

      init_file_descriptor(kernel, io_type)

      io_type
    end
  end
end
