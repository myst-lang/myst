require "colorize"

module Myst
  class Location
    property file   : String
    property line   : Int32
    property col    : Int32
    property length : Int32

    def initialize(@file="", @line=0, @col=0, @length=0)
    end

    def to_s(colorize=false)
      was_coloring = Colorize.enabled?
      Colorize.enabled = colorize
      location_str =  "#{@file || "anonymous"}".colorize(:dark_gray).to_s +
                      ":#{@line}".colorize(:blue).to_s +
                      ":#{@col}".colorize(:dark_gray).mode(:dim).to_s
      Colorize.enabled = was_coloring
      location_str
    end

    def dirname : String?
      file.try { |filename| File.dirname(filename) }
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
