module Myst
  class TFunctor < TObject
    def ==(other : TFunctor) : TBoolean
      TBoolean.new(false)
    end

    def !=(other : TFunctor) : TBoolean
      TBoolean.new(true)
    end
  end
end
