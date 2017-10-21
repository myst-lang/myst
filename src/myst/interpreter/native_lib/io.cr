module Myst
  IO_MODULE = TModule.new
  IO_MODULE.scope["puts"] = TFunctor.new([
    TNativeDef.new(-1) do |_this, args, _block, itr|
      if args.size == 0
        itr.output.puts
      else
        args.each do |arg|
          string = NativeLib.call_func_by_name(itr, arg, "to_s", [] of Value)
          if string.is_a?(TString)
            itr.output.puts(string.value)
          else
            raise RuntimeError.new(TString.new("expected String argument. Got #{string.type.name}"))
          end
        end
      end

      TNil.new
    end
  ] of Callable)
end
