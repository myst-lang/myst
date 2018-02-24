module Myst
  class Interpreter
    NativeLib.method :io_fd_init, TInstance, fd : Int64 do
      id = fd.to_i32
      @fd_pool[id] ||= IO::FileDescriptor.new(id)

      this.ivars["fd"] = fd.to_i64
    end

    NativeLib.method :io_fd_read, TInstance, size : Int64 do
      fd_id = this.ivars["fd"].as(Int64).to_i32
      fd = @fd_pool[fd_id]

      slice = Slice(UInt8).new(size)
      fd.read(slice)
      String.new(slice)
    end

    NativeLib.method :io_fd_write, TInstance, content : String do
      fd_id = this.ivars["fd"].as(Int64).to_i32
      fd = @fd_pool[fd_id]

      fd.write(content.to_slice)
      TNil.new
    end

    def init_file_descriptor(kernel : TModule, io_type : TType)
      io_fd_type = TType.new("FileDescriptor", kernel.scope, io_type)
      io_type.scope["FileDescriptor"] = io_fd_type

      NativeLib.def_instance_method(io_fd_type, :initialize,  :io_fd_init)
      NativeLib.def_instance_method(io_fd_type, :read,        :io_fd_read)
      NativeLib.def_instance_method(io_fd_type, :write,       :io_fd_write)

      io_fd_type
    end
  end
end
