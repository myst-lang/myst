module Myst
  class Interpreter
    def init_io(root_scope : Scope)
      io_module = TModule.new("IO", root_scope)

      io_module.scope["puts"] = TFunctor.new([
        TNativeDef.new(-1) do |_this, args, _block, itr|
          if args.size == 0
            itr.output.puts
          else
            args.each do |arg|
              string = NativeLib.call_func_by_name(itr, arg, "to_s", [] of Value)
              if string.is_a?(TString)
                itr.output.puts(string.value)
              else
                raise RuntimeError.new(TString.new("expected String argument. Got #{__typeof(string).name}"))
              end
            end
          end

          TNil.new
        end
      ] of Callable)

      io_module
    end
  end
end
