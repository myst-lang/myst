module Myst
  class Interpreter
    NativeLib.method :io_read, Value, size : TInteger do
      __raise_runtime_error("`IO#read` must be implemented by inheriting types.")
    end

    NativeLib.method :io_write, Value, content : Value do
      __raise_runtime_error("`IO#write` must be implemented by inheriting types.")
    end

    private def make_io_fd(type : TType, id : Int)
      fd = TInstance.new(type)
      fd.ivars["fd"] = TInteger.new(id.to_i64)
      fd
    end

    def init_io(kernel : TModule)
      io_type = TType.new("IO", kernel.scope)

      NativeLib.def_instance_method(io_type, :read, :io_read)
      NativeLib.def_instance_method(io_type, :write, :io_write)

      fd_type = init_file_descriptor(kernel, io_type)

      kernel.scope["STDIN"]   = make_io_fd(fd_type, 0)
      kernel.scope["STDOUT"]  = make_io_fd(fd_type, 1)
      kernel.scope["STDERR"]  = make_io_fd(fd_type, 2)

      file_type = init_file(kernel, fd_type)

      io_type
    end
  end
end
