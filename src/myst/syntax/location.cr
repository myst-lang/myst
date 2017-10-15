module Myst
  class Location
    property file   : String
    property line   : Int32
    property col    : Int32
    property length : Int32

    def initialize(@file="", @line=0, @col=0, @length=0)
    end

    def to_s
      "#{@file || "unknown"}:#{@line}:#{@col}"
    end

    def to_s(io : IO)
      io << to_s
    end

    def inspect
      to_s
    end

    def inspect(io : IO)
      to_s(io)
    end
  end
end
