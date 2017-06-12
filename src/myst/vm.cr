require "./vm/*"

module Myst
  module VM
    class VM
      property isequences       : Hash(String, InstructionSequence)
      property program_counter  : Int32
      property stack            : Array(MTValue)
      property labels           : Hash(String, Int32)
      property symbol_table     : SymbolTable

      # Setup

      def initialize
        @isequences = {} of String => InstructionSequence
        @program_counter = 0
        @stack = [] of MTValue
        @labels = {} of String => Int32
        @symbol_table = SymbolTable.new
      end

      def load_isequence(file_name : String)
        File.open(file_name) do |io|
          @isequences[file_name] = InstructionSequence.new(io)
        end
      end

      def reset
        @program_counter = 0
        @stack = [] of MTValue
        @labels = {} of String => Int32
        @symbol_table = SymbolTable.new
      end


      # Execution

      def current_instruction
        @instructions[@program_counter]?
      end

      def advance_program_counter
        @program_counter += 1
      end

      def jump_to(target)
        @program_counter = @labels[target]
      end

      def run
        @isequences.each do |name, sequence|
          sequence.instructions.each do |inst|
            execute(inst)
          end
        end
      end


      def execute(nop : Instruction::Nop)
        # No op
      end

      def execute(op : Instruction::Push)
        stack.push(op.value)
      end

      def execute(op : Instruction::Add)
        b = stack.pop
        a = stack.pop

        stack.push(a + b)
      end

      def execute(op : Instruction::Write)
        a = stack.last

        puts a.to_s
      end
    end
  end
end
