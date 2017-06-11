require "./vm/*"

module Myst
  module VM
    class VM
      alias MTValue = Float64

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
      end
    end
  end
end
