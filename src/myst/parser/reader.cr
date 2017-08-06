module Myst
  class Reader
    property source : IO
    property buffer : IO::Memory
    property pos : Int32
    property current_char : Char

    def initialize(@source : IO)
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
      if (slice = @source.peek) && !slice.empty?
        slice[0].chr
      else
        '\0'
      end
    end

    def finished? : Bool
      if slice = @source.peek
        slice.empty?
      else
        true
      end
    end

    def buffer_value
      buffer.to_s[0..-2]
    end
  end
end
