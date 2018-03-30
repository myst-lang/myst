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

    # Generate the code needed to create a passthrough method for some native
    # Crystal method. `call` is a `Call` node representing the structure of the
    # method being wrapped. For example:
    #
    #   NativeLib.passthrough File.basename(path : String)
    #
    # This will generate the code:
    #
    #   NativeLib.method :passthrough_File_basename, MTValue, path : String do
    #     File.basename(path)
    #   end
    #
    # If a method is expected to return nil, set `return_nil` to true. This will
    # ensure that the method _explicitly_ returns Myst's `TNil` value.
    #
    # If the native method may raise an error, set `may_raise` to the type of the
    # expected errors. This will ensure that any raised error is captured and
    # instead raised as a Myst runtime error (meaning users will be able to catch
    # it at runtime). Errors that are not of the given type will _not_ be captured
    # and will be shown as Interpreter Errors to the user.
    #
    # Note that using this method _requires_ that the given Call provide type
    # restrictions for every argument.
    macro passthrough(call, return_nil=false, may_raise=nil)
      NativeLib.method :passthrough_{{call.receiver}}_{{call.name}}, MTValue, {{*call.args}} do
        {{call.receiver}}.{{call.name}}({{ *call.args.map{ |a| a.var } }})
        {% if return_nil %}
          TNil.new
        {% end %}

      {% begin %}
        {% if may_raise %}
          rescue ex : {{may_raise}}
            __raise_runtime_error(ex.message || "Unknown error in native method `{{call.name}}`")
        {% end %}
      {% end %}

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
