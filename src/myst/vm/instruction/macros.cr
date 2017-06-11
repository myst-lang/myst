require "./base"

module Myst
  module VM
    module Instruction
      TYPES = { -1 => Base }

      macro def_parser
        def self.parse_next(io : IO)
          case opcode = io.read_byte
          {% for code, type in TYPES %}
            when {{code}}
              {{type}}.new(io)
          {% end %}
          when nil
            return nil
          else
            raise "Invalid opcode: #{opcode}"
          end
        end
      end

      macro def_instruction(name, opcode, *arguments)
        class {{name.id}} < Base
          {% for arg in arguments %}
            getter {{arg}}
          {% end %}

          def initialize(io : IO)
            {% for arg in arguments %}
              @{{arg.var}} = {{arg.type}}.from_io(io)
            {% end %}
          end

          def initialize({{ *arguments.map{ |a| "@#{a.var}".id } }}); end

          def opcode : UInt8
            {{opcode}}
          end

          {{yield}}
        end

        {% TYPES[opcode] = name.id %}
      end
    end
  end
end
