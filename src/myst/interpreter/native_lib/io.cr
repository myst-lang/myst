module Myst
  class Interpreter
    NativeLib.method :io_puts, Value do
      if __args.size == 0
        self.output.puts
      else
        __args.each do |arg|
          string = NativeLib.call_func_by_name(self, arg, "to_s", [] of Value)
          if string.is_a?(TString)
            self.output.puts(string.value)
          else
            raise RuntimeError.new(TString.new("expected String argument. Got #{__typeof(string).name}"), self.callstack)
          end
        end
      end

      TNil.new
    end


    def init_io(root_scope : Scope)
      io_module = TModule.new("IO", root_scope)

      NativeLib.def_method(io_module, :puts, :io_puts)

      io_module
    end
  end
end
