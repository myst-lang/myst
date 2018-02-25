module Myst
  module NativeLib
    extend self

    # Mimic the functionality of a Call, but without the lookup of the
    # function. The function can be either a native function or a source-level
    # function. The results do not affect the stack, the result of calling the
    # function will be returned directly.
    def call_func(itr, func : TFunctor, args : Array(MTValue), receiver : MTValue?=nil)
      Invocation.new(itr, func, receiver, args, nil).invoke
    end

    # Same as `call_func`, but the function to call is given as a name to
    # look up on the given receiver.
    def call_func_by_name(itr, receiver : MTValue, name : String, args : Array(MTValue))
      func = itr.__scopeof(receiver)[name].as(TFunctor)
      Invocation.new(itr, func, receiver, args, nil).invoke
    end

    # Instantiate a given type and invoke its initializer
    def instantiate(itr, type : TType, params : Array(MTValue)) : TInstance
      instance = TInstance.new(type)

      if (initializer = instance.scope["initialize"]?) && initializer.is_a?(TFunctor)
        Invocation.new(itr, initializer, instance, params, nil).invoke
      end

      instance
    end

    macro method(name, this_type, *params, &block)
      def {{name.id}}(this : MTValue, __args : Array(MTValue), block : TFunctor?) : MTValue
        this = this.as({{this_type}})

        {% for type, index in params %}
          {{params[index].var}} = __args[{{index}}]?.as({{params[index].type}})
        {% end %}

        %result = begin
          {{block.body}}
        end

        %result.as(MTValue)
      end
    end

    macro def_method(type, name, impl_name)
      {{type}}.scope["{{name.id}}"] = TFunctor.new("{{name.id}}", [
        ->{{impl_name.id}}(MTValue, Array(MTValue), TFunctor?).as(Callable)
      ] of Callable)
    end

    macro def_instance_method(type, name, impl_name)
      {{type}}.instance_scope["{{name.id}}"] = TFunctor.new("{{name.id}}", [
        ->{{impl_name.id}}(MTValue, Array(MTValue), TFunctor?).as(Callable)
      ] of Callable)
    end
  end
end

require "./native_lib/*"
