module Myst
  class TObject < Scope
    def self.type_name; "Object"; end
    def type_name; self.class.type_name; end
  end
end
