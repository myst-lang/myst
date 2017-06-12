module Myst
  class Location
    property line   : Int32
    property col    : Int32
    property length : Int32

    def initialize(@line=0, @col=0, @length=0)
    end
  end
end
