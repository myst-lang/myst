module Myst
  class Interpreter
    def self.__value_from_literal(literal : Node)
      case literal
      when IntegerLiteral
        literal.value.to_i64
      when FloatLiteral
        literal.value.to_f64
      when StringLiteral
        literal.value
      when SymbolLiteral
        TSymbol.new(literal.value)
      when BooleanLiteral
        literal.value
      when NilLiteral
        TNil.new
      else
        raise "Interpreter Bug: Attempting to create an MTValue from a #{literal.class}, which is not a valid Literal type."
      end
    end

    # Resolve the TType object representing the type of `value`. For primitive
    # types, these are _always_ looked up in the Kernel. For Instances, the
    # type is looked up from the type reference on the instance itself. For
    # Types and Modules, the value itself is returned.
    def __typeof(value : MTValue)
      case value
      when ContainerType
        value
      when TInstance
        value.type
      when MTValue
        @kernel.scope[value.type_name].as(TType)
      else
        __raise_runtime_error("Can't resolve type of #{value}")
      end
    end

    # Resolve the Scope for `value`. For primitives, this returns the instance
    # scope of the Type for that value. For Instances, Types, and Modules, this
    # just returns `.scope` for that value.
    def __scopeof(value : MTValue, prefer_instance_scope = false) : Scope
      case value
      when TInstance
        value.scope
      when TType
        prefer_instance_scope ? value.instance_scope : value.scope
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
      if  {{value}}.is_a?(Int64) || {{value}}.is_a?(Float64) ||
          {{value}}.is_a?(TNil) || {{value}}.is_a?(Bool) ||
          {{value}}.is_a?(String)
        __raise_runtime_error({{operation || "Operation disallowed on primitive types"}})
      end
    end


    # Lookup a value under the given name in the current scope or one of its
    # ancestors. If the value is not found, a `No variable or method`
    # RuntimeError will be raised.
    def lookup(node)
      unless (value = current_scope[node.name]?).nil?
        value
      else
        __raise_not_found(node.name, current_self)
      end
    end

    # Attempt to lookup the given name recursively through the ancestry of the
    # given receiver. This is mainly used for method lookup, where the simple
    # `lookup` method does not search deep enough for a value.
    #
    # The method will return `nil` if no matching entry is found.
    def recursive_lookup(receiver, name, check_current = true)
      func = current_scope[name] if check_current && current_scope.has_key?(name)
      if func.nil?
        func = __scopeof(receiver)[name]?
      end

      if func.nil?
        case receiver
        when TType
          func ||= receiver.extended_ancestors.each do |anc|
            unless (found = __scopeof(anc)[name]?).nil?
              break found
            end
          end
        else
          func ||= __typeof(receiver).ancestors.each do |anc|
            unless (found = __scopeof(anc, prefer_instance_scope: true)[name]?).nil?
              break found
            end
          end
        end
      end

      func
    end


    def __raise_not_found(name, value : MTValue?)
      type_name = __typeof(value).name
      error_message = "No variable or method `#{name}` for #{type_name}"

      if value_to_s = __scopeof(value)["to_s"]?
        value_str = NativeLib.call_func_by_name(self, value, "to_s", [] of MTValue)
        error_message = "No variable or method `#{name}` for #{value_str}:#{type_name}"
      end

      __raise_runtime_error(error_message)
    end


    # Raise a RuntimeError from the current location. Execution is immediataly
    # halted and the interpreter will panic up until a rescuer is found.
    #
    # Multiple overloads of this function are provided for simplicity at the
    # call site.
    def __raise_runtime_error(message : String)
      raise RuntimeError.new(message, callstack)
    end

    def __raise_runtime_error(value : MTValue)
      raise RuntimeError.new(value, callstack)
    end

    def __raise_runtime_error(error : RuntimeError)
      raise error
    end
  end
end
