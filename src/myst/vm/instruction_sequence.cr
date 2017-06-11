module Myst
  module VM
    class InstructionSequence
      property instructions : Array(Instruction::Base)

      def initialize(@instructions=[] of Instruction::Base)
      end

      def initialize(io : IO)
        @instructions = [] of Instruction::Base
        while inst = Instruction.parse_next(io)
          @instructions.push(inst)
        end
      end

      def disasm(io : IO)
        @instructions.each do |inst|
          io.printf("%-12s\t%s\n", inst.display_name, inst.arguments.join(' '))
        end
      end
    end
  end
end
