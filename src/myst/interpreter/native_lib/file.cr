module Myst
  class Interpreter
    NativeLib.passthrough(File.basename(path : String))
    NativeLib.passthrough(File.chmod(path : String, mode : Int64), return_nil: true)
    NativeLib.passthrough(File.delete(path : String), return_nil: true, may_raise: Errno)
    NativeLib.passthrough(File.directory?(path : String))
    NativeLib.passthrough(File.dirname(path : String))
    NativeLib.passthrough(File.empty?(path : String), may_raise: Errno)
    NativeLib.passthrough(File.executable?(path : String))
    NativeLib.passthrough(File.exists?(path : String))
    NativeLib.passthrough(File.expand_path(path : String))
    NativeLib.passthrough(File.extname(path : String))
    NativeLib.passthrough(File.file?(path : String))
    NativeLib.passthrough(File.read(path : String), may_raise: Errno)
    NativeLib.passthrough(File.readable?(path : String))
    NativeLib.passthrough(File.real_path(path : String))
    NativeLib.passthrough(File.symlink?(path : String))
    NativeLib.passthrough(File.writable?(path : String))
    NativeLib.passthrough(File.touch(path : String), return_nil: true)

    # TODO: For some weird reason, generating these with the
    # `NativeLib.passthrough` macro causes a compile error saying "undefined
    # method 'check_no_null_byte' for Nil" for the arguments, even though they
    # are being restricted to just `String`.
    NativeLib.method :passthrough_File_link, MTValue, old_path : String, new_path : String do
      File.link(old_path, new_path)
      TNil.new
    end

    NativeLib.method :passthrough_File_rename, MTValue, old_name : String, new_name : String do
      File.rename(old_name, new_name)
      TNil.new
    rescue ex : Errno
      __raise_runtime_error(ex.message || "Unknown error in native method `{{call.name}}`")
    end

    NativeLib.method :passthrough_File_symlink, MTValue, old_path : String, new_path : String do
      File.symlink(old_path, new_path)
      TNil.new
    end

    NativeLib.method :passthrough_File_write, MTValue, path : String, content : String do
      File.write(path, content)
      TNil.new
    end

    # TODO: This method cannot currently be generated as a passthrough because
    # it returns a `UInt64`. Currently, it has to manually be cast into an
    # `Int64`, because Myst does not have an unsigned numeric type.
    # This may also cause a casting error with very-large files.
    NativeLib.method :passthrough_File_size, MTValue, path : String do
      File.size(path).to_i64
    end

    NativeLib.method :static_File_join, MTValue do
      # Crystal's `File.join` expects the arguments to be "string-like". To
      # match this, the given arguments need to be "casted" into Strings. Any
      # non-string arguments
      string_args = __args.map do |arg|
        case arg
        when String
          arg
        else
          arg_string = NativeLib.call_func_by_name(self, arg, "to_s", [] of MTValue)
          __raise_runtime_error("`File.join` expects only String arguments, but was given `#{arg_string}` (#{__typeof(arg).name})")
        end
      end

      File.join(string_args)
    end


    NativeLib.method :static_File_each_line, MTValue, file_name : String do
      if block
        File.each_line(file_name) do |line|
          NativeLib.call_func(self, block, [line] of MTValue, nil)
        end
      end

      TNil.new
    end

    NativeLib.method :static_File_lines, MTValue, file_name : String do
      lines = File.open(file_name) do |file| 
        file.each_line.map { |l| l.as(MTValue) }.to_a
      end

      TList.new(lines)
    end



    NativeLib.method :file_init, TInstance, path : String, mode : String do
      file = File.open(path, mode)
      @fd_pool[file.fd] = file

      this.ivars["@path"] = path
      this.ivars["@mode"] = mode
      this.ivars["@fd"] = file.fd.to_i64
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



    def init_file(fd_type : TType)
      file_type = __make_type("File", @kernel.scope, parent_type: fd_type)

      NativeLib.def_method(file_type, :basename,    :passthrough_File_basename)
      NativeLib.def_method(file_type, :chmod,       :passthrough_File_chmod)
      NativeLib.def_method(file_type, :delete,      :passthrough_File_delete)
      NativeLib.def_method(file_type, :directory?,  :passthrough_File_directory?)
      NativeLib.def_method(file_type, :dirname,     :passthrough_File_dirname)
      NativeLib.def_method(file_type, :each_line,   :static_File_each_line)
      NativeLib.def_method(file_type, :empty?,      :passthrough_File_empty?)
      NativeLib.def_method(file_type, :executable?, :passthrough_File_executable?)
      NativeLib.def_method(file_type, :exists?,     :passthrough_File_exists?)
      NativeLib.def_method(file_type, :expand_path, :passthrough_File_expand_path)
      NativeLib.def_method(file_type, :extname,     :passthrough_File_extname)
      NativeLib.def_method(file_type, :file?,       :passthrough_File_file?)
      NativeLib.def_method(file_type, :lines,       :static_File_lines)
      NativeLib.def_method(file_type, :join,        :static_File_join)
      NativeLib.def_method(file_type, :readable?,   :passthrough_File_readable?)
      NativeLib.def_method(file_type, :read,        :passthrough_File_read)
      NativeLib.def_method(file_type, :real_path,   :passthrough_File_real_path)
      NativeLib.def_method(file_type, :size,        :passthrough_File_size)
      NativeLib.def_method(file_type, :symlink,     :passthrough_File_symlink)
      NativeLib.def_method(file_type, :touch,       :passthrough_File_touch)
      NativeLib.def_method(file_type, :writable?,   :passthrough_File_writable?)
      NativeLib.def_method(file_type, :write,       :passthrough_File_write)

      NativeLib.def_instance_method(file_type, :initialize, :file_init)
      NativeLib.def_instance_method(file_type, :close,      :file_close)
      NativeLib.def_instance_method(file_type, :size,       :file_size)
      file_type
    end
  end
end
