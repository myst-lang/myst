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

    NativeLib.method :io_print, Value do
      if __args.size == 0
        self.output.print("")
      else
        __args.each do |arg|
          string = NativeLib.call_func_by_name(self, arg, "to_s", [] of Value)
          if string.is_a?(TString)
            self.output.print(string.value)
          else
            raise RuntimeError.new(TString.new("expected String argument. Got #{__typeof(string).name}"), self.callstack)
          end
        end
      end

      TNil.new
    end

    NativeLib.method :io_gets, Value do
      input = self.input.gets
      if input
        TString.new(input)
      else
        TNil.new
      end
    end

    def init_io(kernel : TModule)
      io_module = TModule.new("IO", kernel.scope)

      NativeLib.def_method(io_module, :puts, :io_puts)
      NativeLib.def_method(io_module, :print, :io_print)
      NativeLib.def_method(io_module, :gets, :io_gets)

      io_module
    end
  end
end
