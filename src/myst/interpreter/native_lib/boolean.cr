module Myst
  class Interpreter
    def init_boolean(root_scope : Scope)
      boolean_type = TType.new("Boolean", root_scope)

      boolean_type.instance_scope["to_s"] = TFunctor.new([
        TNativeDef.new(0) do |this, _args, _block, _itr|
          TString.new(this.as(TBoolean).value ? "true" : "false")
        end
      ] of Callable)

      boolean_type.instance_scope["=="] = TFunctor.new([
        TNativeDef.new(1) do |this, (arg), _block, _itr|
          this = this.as(TBoolean)
          case arg
          when TBoolean
            TBoolean.new(this.value == arg.value)
          else
            TBoolean.new(false)
          end
        end
      ] of Callable)

      boolean_type.instance_scope["!="] = TFunctor.new([
        TNativeDef.new(1) do |this, (arg), _block, _itr|
          this = this.as(TBoolean)
          case arg
          when TBoolean
            TBoolean.new(this.value != arg.value)
          else
            TBoolean.new(true)
          end
        end
      ] of Callable)

      boolean_type
    end
  end
end
