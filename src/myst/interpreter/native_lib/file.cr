module Myst
  class Interpreter
    NativeLib.method :file_init, TInstance, name : TString, mode : TString do
      file = File.open(name.value, mode.value)
      @fd_pool[file.fd] = file

      this.ivars["fd"] = TInteger.new(file.fd.to_i64)
      this
    end

    NativeLib.method :file_close, TInstance do
      fd = this.ivars["fd"].as(TInteger)
      file = @fd_pool[fd.value]
      file.close
      @fd_pool.delete(fd.value)
      TNil.new
    end


    def init_file(kernel : TModule, fd_type : TType)
      file_type = TType.new("File", kernel.scope, fd_type)
      kernel.scope["File"] = file_type

      NativeLib.def_instance_method(file_type, :initialize, :file_init)
      NativeLib.def_instance_method(file_type, :close,      :file_close)
      file_type
    end
  end
end
