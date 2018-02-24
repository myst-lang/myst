module Myst
  class Interpreter
    NativeLib.method :file_init, TInstance, name : String, mode : String do
      file = File.open(name, mode)
      @fd_pool[file.fd] = file

      this.ivars["@fd"] = file.fd.to_i64
      this.ivars["@mode"] = mode
      this
    end

    NativeLib.method :file_close, TInstance do
      fd = this.ivars["@fd"].as(Int64)
      file = @fd_pool[fd]
      file.close
      @fd_pool.delete(fd)
      TNil.new
    end

    NativeLib.method :file_size, TInstance do
      fd = this.ivars["@fd"].as(Int64)
      file = @fd_pool[fd].as(File)
      file.size.to_i64
    end


    def init_file(kernel : TModule, fd_type : TType)
      file_type = TType.new("File", kernel.scope, fd_type)
      kernel.scope["File"] = file_type

      NativeLib.def_instance_method(file_type, :initialize, :file_init)
      NativeLib.def_instance_method(file_type, :close,      :file_close)
      NativeLib.def_instance_method(file_type, :size,       :file_size)
      file_type
    end
  end
end
