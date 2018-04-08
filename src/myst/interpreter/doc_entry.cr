require "./value.cr"

module Myst
  struct DocEntry
    property reference : String
    property returns   : String?
    property content   : String

    def initialize(@reference : String, @returns : String?, @content : String)
      @children = Hash(String, DocEntry).new
    end

    def basename : String
      reference.split(/\#|\./).last
    end
  end
end
