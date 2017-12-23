module Myst
  class Interpreter
    @file_pool = {
      0 => File.open("/dev/stdin", "r"),
      1 => File.open("/dev/stdout", "w"),
      2 => File.open("/dev/stderr", "w")
    } of Int32 => File

    NativeLib.method :fs_utils_open, Value, name : TString, mode : TString do
      file = File.open(name.value, mode.value)
      @file_pool[file.fd] = file
      TInteger.new(file.fd.to_i64)
    end

    NativeLib.method :fs_utils_close, Value, fd : TInteger do
      file = @file_pool[fd.value]
      file.close
      @file_pool.delete(fd.value)
      TBoolean.new(true)
    end

    NativeLib.method :fs_utils_size, Value, fd : TInteger do
      file = @file_pool[fd.value]
      TInteger.new(file.size.to_i64)
    end

    NativeLib.method :fs_utils_read_all, Value, fd : TInteger do
      file = @file_pool[fd.value]
      data = Slice(UInt8).new(file.size)
      file.read(data)
      TString.new(String.new(data))
    end

    NativeLib.method :fs_utils_read, Value, fd : TInteger, length : TInteger do
      file = @file_pool[fd.value]
      data = Slice(UInt8).new(length.value)
      file.read(data)
      TString.new(String.new(data))
    end

    NativeLib.method :fs_utils_write, Value, fd : TInteger, data : Value do
      file = @file_pool[fd.value]
      data_str = NativeLib.call_func_by_name(self, data, "to_s", [] of Value).as(TString)
      file.write(data_str.value.to_slice)
      TNil.new
    end


    def init_file_utils(kernel : TModule)
      fs_utils_module = TModule.new("FSUtils", kernel.scope)

      NativeLib.def_method(fs_utils_module, :open,      :fs_utils_open)
      NativeLib.def_method(fs_utils_module, :close,     :fs_utils_close)
      NativeLib.def_method(fs_utils_module, :size,      :fs_utils_size)
      NativeLib.def_method(fs_utils_module, :read,      :fs_utils_read)
      NativeLib.def_method(fs_utils_module, :read_all,  :fs_utils_read_all)
      NativeLib.def_method(fs_utils_module, :write,     :fs_utils_write)

      fs_utils_module
    end
  end
end
