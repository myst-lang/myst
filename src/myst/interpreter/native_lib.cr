module Myst
  module NativeLib
    extend self

    # Mimic the functionality of a Call, but without the lookup of the
    # function. The function can be either a native function or a source-level
    # function. The results do not affect the stack, the result of calling the
    # function will be returned directly.
    def call_func(itr, func : TFunctor, args : Array(Value), receiver : Value?=nil)
      Invocation.new(itr, func, receiver, args, nil).invoke
    end

    # Same as `call_func`, but the function to call is given as a name to
    # look up on the given receiver.
    def call_func_by_name(itr, receiver : Value, name : String, args : Array(Value))
      func = receiver.scope[name].as(TFunctor)
      Invocation.new(itr, func, receiver, args, nil).invoke
    end
  end
end

require "./native_lib/*"
