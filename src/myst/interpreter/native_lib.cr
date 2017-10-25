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
      func = itr.__scopeof(receiver)[name].as(TFunctor)
      Invocation.new(itr, func, receiver, args, nil).invoke
    end

    macro method(name, this_type, *params, &block)
      def {{name.id}}(this : Value, __args : Array(Value), block : TFunctor?) : Value
        this = this.as({{this_type}})

        {% for type, index in params %}
          {{params[index].var}} = __args[{{index}}].as({{params[index].type}})
        {% end %}

        result = begin
          {{block.body}}
        end

        result.as(Value)
      end
    end

    macro def_method(type, name, impl_name)
      {{type}}.scope["{{name.id}}"] = TFunctor.new([
        ->{{impl_name.id}}(Value, Array(Value), TFunctor?).as(Callable)
      ] of Callable)
    end

    macro def_instance_method(type, name, impl_name)
      {{type}}.instance_scope["{{name.id}}"] = TFunctor.new([
        ->{{impl_name.id}}(Value, Array(Value), TFunctor?).as(Callable)
      ] of Callable)
    end
  end
end

require "./native_lib/*"
