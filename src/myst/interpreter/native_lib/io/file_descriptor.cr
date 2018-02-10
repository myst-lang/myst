module Myst
  class Interpreter
    NativeLib.method :io_fd_init, TInstance, fd : TInteger do
      id = fd.value.to_i32
      @fd_pool[id] ||= IO::FileDescriptor.new(id)

      this.ivars["fd"] = fd
    end

    NativeLib.method :io_fd_read, TInstance, size : TInteger do
      fd_id = this.ivars["fd"].as(TInteger).value.to_i32
      fd = @fd_pool[fd_id]

      slice = Slice(UInt8).new(size.value)
      fd.read(slice)
      TString.new(String.new(slice))
    end

    NativeLib.method :io_fd_write, TInstance, content : TString do
      fd_id = this.ivars["fd"].as(TInteger).value.to_i32
      fd = @fd_pool[fd_id]

      fd.write(content.value.to_slice)
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
