module Myst
  module VM
    module Bytecode
      extend self

      def from_file(file_name : String) : Array(Instruction::Base)
        instruction_buffer = [] of Instruction::Base
        File.open(file_name) do |io|
          while opcode = io.read_byte
            instruction_buffer.push(Instruction.parse_next(io))
          end
        end

        instruction_buffer
      end


      # Return the instructions in this buffer in a String format suitable for
      # writing to a file.
      def dump(instructions : InstructionSequence)
        String.build{ |str| dump(str) }
      end

      # Write the instructions in this buffer in a String format into `io`.
      def dump(instructions : InstructionSequence, io : IO)
        instructions.each do |inst|
          io << inst << "\n"
        end
      end
    end
  end
end
