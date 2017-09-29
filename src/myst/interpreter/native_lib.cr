module Myst
  module NativeLib
    extend self

    # Mimic the functionality of a Call, but without the lookup of the
    # function. The function can be either a native function or a source-level
    # function. The results do not affect the stack, the result of calling the
    # function will be returned directly.
    def call_func(itr, func, *args, receiver : Value?=nil)
      case func
      when TFunctor
        itr.do_call(func, receiver, args.to_a, nil)
      when TNativeFunctor
        itr.do_call(func, receiver, args.to_a, nil)
      else
        raise "func is not callable."
      end
    end
  end
end

require "./native_lib/*"
