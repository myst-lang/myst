module Myst
  class Interpreter
    def init_nil(root_scope : Scope)
      nil_type = TType.new("Nil", root_scope)

      nil_type.instance_scope["to_s"] = TFunctor.new([
        TNativeDef.new(0) do |_this, _args, _block, _itr|
          TString.new("nil")
        end
      ] of Callable)

      nil_type.instance_scope["=="] = TFunctor.new([
        TNativeDef.new(1) do |this, (arg), _block, _itr|
          this = this.as(TNil)
          case arg
          when TNil
            TBoolean.new(true)
          else
            TBoolean.new(false)
          end
        end
      ] of Callable)

      nil_type.instance_scope["!="] = TFunctor.new([
        TNativeDef.new(1) do |this, (arg), _block, _itr|
          this = this.as(TNil)
          case arg
          when TNil
            TBoolean.new(false)
          else
            TBoolean.new(true)
          end
        end
      ] of Callable)

      nil_type
    end
  end
end
