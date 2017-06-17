module Myst
  class TBoolean < Primitive(Bool)
    simple_op :==, TBoolean, returns: TBoolean
    simple_op :!=, TBoolean, returns: TBoolean

    def to_s
      value ? "true" : "false"
    end

    def truthy?
      self.value
    end
  end
end
