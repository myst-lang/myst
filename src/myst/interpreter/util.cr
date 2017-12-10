module Myst
  class Interpreter
    # Resolve the TType object representing the type of `value`. For primitive
    # types, these are _always_ looked up in the Kernel. For Instances, the
    # type is looked up from the type reference on the instance itself. For
    # Types and Modules, the value itself is returned.
    def __typeof(value : Value)
      case value
      when ContainerType
        value
      when TInstance
        value.type
      when Value
        @kernel.scope[value.type_name].as(TType)
      else
        raise "Can't resolve type of #{value}"
      end
    end

    # Resolve the Scope for `value`. For primitives, this returns the instance
    # scope of the Type for that value. For Instances, Types, and Modules, this
    # just returns `.scope` for that value.
    def __scopeof(value : Value) : Scope
      case value
      when TInstance
        value.scope
      when ContainerType
        value.scope
      else
        __typeof(value).as(TType).instance_scope
      end
    end

    # Primitive types have some restrictions on functionality. This method will
    # raise an appropriate error if the given value is a primitive.
    # If `operation` is given, it will be used as the error message.
    macro __disallow_primitives(value, operation=nil)
      if  {{value}}.is_a?(TInteger) || {{value}}.is_a?(TFloat) ||
          {{value}}.is_a?(TNil) || {{value}}.is_a?(TBoolean) ||
          {{value}}.is_a?(TString)
        raise {{operation || "Operation disallowed on primitive types"}}
      end
    end


    # Lookup a value under the given name in the current scope or one of its
    # ancestors. If the value is not found, a `No variable or method`
    # RuntimeError will be raised.
    def lookup(node)
      if value = current_scope[node.name]?
        value
      else
        @callstack.push(node)
        raise_not_found(node.name, current_self)
      end
    end

    # Attempt to lookup the given name recursively through the ancestry of the
    # given receiver. This is mainly used for method lookup, where the simple
    # `lookup` method does not search deep enough for a value.
    #
    # The method will return `nil` if no matching entry is found.
    def recursive_lookup(receiver, name)
      func    = current_scope[name] if current_scope.has_key?(name)
      func  ||= __scopeof(receiver)[name]?
      func  ||= __typeof(receiver).ancestors.each do |anc|
        if found = __scopeof(anc)[name]?
          break found
        end
      end

      func
    end

    def raise_not_found(name, value)
      type_name = __typeof(value).name
      error_message = "No variable or method `#{name}` for #{type_name}"

      if value_to_s = __scopeof(value)["to_s"]?
        value_to_s = value_to_s.as(TFunctor)
        value_str = Invocation.new(self, value_to_s, value, [] of Value, nil).invoke.as(TString).value
        error_message = "No variable or method `#{name}` for #{value_str}:#{type_name}"
      end

      raise RuntimeError.new(TString.new(error_message), callstack)
    end
  end
end
