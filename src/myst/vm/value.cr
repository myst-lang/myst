module Myst
  module VM
    class MTValue
      alias BaseType = Int64 | Float64 | String | Nil

      property value : BaseType
      property type_code : UInt8

      def initialize
        @value = nil
        @type_code = 0x00_u8
      end
      def initialize(@value : Int64)
        @type_code = 0x01_u8
      end
      def initialize(@value : Float64)
        @type_code = 0x02_u8
      end
      def initialize(@value : String)
        @type_code = 0x04_u8
      end


      def is_int?;      value.is_a?(Int64); end
      def is_float?;    value.is_a?(Float64); end
      def is_numeric?;  value.is_a?(Int64 | Float64); end
      def is_string?;   value.is_a?(String); end
      def is_nil?;      value.is_a?(Nil); end

      def as_int;       value.as(Int64); end
      def as_float;     value.as(Float64); end
      def as_numeric;   value.as(Int64 | Float64); end
      def as_string;    value.as(String); end

      def not_nil!;     value.not_nil!; end


      # Arithmetic
      macro def_binary_op(operator)
        def {{operator.id}}(other : MTValue)
          if is_numeric? && other.is_numeric?
            MTValue.new(as_numeric {{operator.id}} other.as_numeric)
          elsif is_string?
            MTValue.new(as_string {{operator.id}} other.to_s)
          else
            MTValue.new
          end
        end
      end

      def_binary_op(:+)
      def_binary_op(:-)
      def_binary_op(:*)
      def_binary_op(:/)

      # IO

      def self.from_io(io : IO)
        case type_code = io.read_byte
        when 0x00 # Nil
          MTValue.new
        when 0x01 # Int
          MTValue.new(io.read_bytes(Int64))
        when 0x02 # Float
          MTValue.new(io.read_bytes(Float64))
        when 0x04
          MTValue.new(io.gets('\0').not_nil!)
        when 0x08
          MTValue.new(io.gets('\0').not_nil!)
        else
          raise "Invalid type code: #{type_code}"
        end
      end

      def to_s
        @value.to_s
      end

      def to_s(io : IO)
        io << to_s
      end

      # Return the string representation of this value with the appropriate
      # type punctuation (e.g., quotes around strings).
      def inspect
        case @value
        when String
          '"' + @value.to_s + '"'
        else
          @value.to_s
        end
      end

      def inspect(io : IO)
        io << inspect
      end

      # Return the representation of this value in binary, including the type
      # code byte prefix.
      def to_bytecode(io : IO)
        io.write_byte(@type_code)
        if (val = @value).is_a?(String)
          # For strings, write the slice, followed by a null terminator
          io.write(val.to_slice)
          io.write_byte(0_u8)
        elsif val
          io.write_bytes(val)
        end
      end
    end
  end
end
