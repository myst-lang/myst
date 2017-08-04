module Myst
  class TBoolean < Primitive(Bool)
    def self.type_name; "Boolean"; end
    def type_name; self.class.type_name; end

    simple_op :==, TBoolean, returns: TBoolean
    simple_op :!=, TBoolean, returns: TBoolean

    def truthy?
      self.value
    end
  end
end
