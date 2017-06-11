module Myst
  module VM
    module Instruction
      class ValueLiteral
        def self.from_io(io : IO)
          case type = io.read_byte
          # when 0x00
          when 0x01
            IntLiteral.new(io)
          # when 0x02
          when 0x04
            StringLiteral.new(io)
          # when 0x08
          else
            raise "Invalid value type: #{type}"
          end
        end
      end

      class IntLiteral < ValueLiteral
        property value : Int64

        def self.from_io(io : IO)
          # Read the type code first, then the value
          io.read_byte
          IntLiteral.new(io)
        end

        def initialize(io : IO)
          @value = io.read_bytes(Int64)
        end

        def to_s(io : IO)
          io << @value
        end
      end


      class StringLiteral < ValueLiteral
        property value : String

        def self.from_io(io : IO)
          # Read the type code first, then the value
          io.read_byte
          StringLiteral.new(io)
        end

        def initialize(io : IO)
          @value = io.gets('\0').not_nil!
        end

        def to_s(io : IO)
          io << "\"#{@value}\""
        end
      end
    end
  end
end
