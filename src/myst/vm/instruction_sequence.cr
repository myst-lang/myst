module Myst
  module VM
    class InstructionSequence
      property instructions : Array(Instruction::Nop)

      def initialize(@instructions=[] of Instruction::Nop)
      end

      def initialize(io : IO)
        @instructions = [] of Instruction::Nop
        while inst = Instruction.parse_next(io)
          @instructions.push(inst)
        end
      end

      def add_instruction(inst : Instruction::Nop)
        @instructions.push(inst)
      end

      def disasm(io : IO)
        @instructions.each do |inst|
          io.printf("%-12s\t%s\n", inst.display_name, inst.arguments.map(&.inspect).join(' '))
        end
      end

      def to_bytecode(io : IO)
        @instructions.each do |inst|
          inst.to_bytecode(io)
        end
      end
    end
  end
end
