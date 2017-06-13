module Myst
  class Location
    property line   : Int32
    property col    : Int32
    property length : Int32

    def initialize(@line=0, @col=0, @length=0)
    end

    def to_s
      "#{@line}:#{@col}:#{@length}"
    end

    def to_s(io : IO)
      io << to_s
    end
  end
end
