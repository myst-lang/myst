module Myst
  class Reader
    property source : IO::Memory
    property buffer : IO::Memory
    property pos : Int32
    property current_char : Char

    def initialize(@source : IO::Memory)
      @buffer = IO::Memory.new
      @pos = 0
      @current_char = read_char
    end

    def read_char : Char
      char = @source.read_char
      char = '\0' unless char.is_a?(Char)

      @current_char = char
      @pos += 1
      @buffer << char

      char
    end

    def peek_char : Char
      char = @source.read_char
      char = '\0' unless char.is_a?(Char)

      if @source.size == 0
        char
      else
        @source.pos -= 1
        char
      end
    end

    def finished? : Bool
      pos-2 >= @source.size
    end

    def buffer_value
      buffer.to_s[0..-2]
    end
  end
end
