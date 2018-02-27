module Myst
  class Doc
    property content : String

    def initialize(@content : String)
    end

    def_equals_and_hash content
  end
end
