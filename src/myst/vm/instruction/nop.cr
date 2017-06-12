module Myst
  module VM
    module Instruction
      class Nop
        property type_name : String?

        def initialize(io : IO); end


        @[AlwaysInline]
        def arguments
          vars = {{ @type.instance_vars }}
          args = [] of MTValue
          vars.each do |arg|
            args.push(arg) if arg.is_a?(MTValue)
          end
          args
        end

        def self.opcode
          0x00_u8
        end

        def opcode
          self.class.opcode
        end


        def display_name : String
          @type_name ||= {{@type.name}}.name.split("::").last.underscore
        end


        def to_bytecode(io : IO)
          io.write_byte(opcode)
          arguments.each do |arg|
            arg.to_bytecode(io)
          end
        end
      end
    end
  end
end
