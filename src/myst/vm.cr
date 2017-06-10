require "./vm/*"

module Myst
  module VM
    class VM
      alias MTValue = Float64

      property instructions     : Array(Instruction)
      property program_counter  : Int32
      property stack            : Array(MTValue)
      property labels           : Hash(String, Int32)
      property symbol_table     : SymbolTable

      # Setup

      def initialize
        @instructions = [] of Instruction
        @program_counter = 0
        @stack = [] of MTValue
        @labels = {} of String => Int32
        @symbol_table = SymbolTable.new
      end

      def load(file_name : String)
        @instructions.concat(Bytecode.from_file(file_name))
      end

      def load(new_code : Array(Instruction))
        @instructions.concat(new_code)
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
        while instruction = current_instruction
          case instruction.type
          when InstructionType::PUSH
            value = instruction.args.first.to_f64
            stack.push(value)
          when InstructionType::LOAD
            identifier = instruction.args.first
            value = @symbol_table[identifier]
            stack.push(value)
          when InstructionType::STORE
            identifier = instruction.args.first
            value = stack.pop
            @symbol_table[identifier] = value
          when InstructionType::ADD
            b = stack.pop
            a = stack.pop
            stack.push(a + b)
          when InstructionType::SUBTRACT
            b = stack.pop
            a = stack.pop
            stack.push(a - b)
          when InstructionType::MULTIPLY
            b = stack.pop
            a = stack.pop
            stack.push(a * b)
          when InstructionType::DIVIDE
            b = stack.pop
            a = stack.pop
            stack.push(a / b)
          when InstructionType::LABEL
            @labels[instruction.args.first] = @program_counter+1
          when InstructionType::JUMP
            if target = instruction.args.first.to_i32?
              @program_counter = target
            else
              jump_to(instruction.args.first)
            end
          when InstructionType::PRINT_STACK
            puts stack
          end

          unless instruction.modifies_program_counter?
            advance_program_counter
          end

          sleep 0.01
        end
      end

      def execute()
      end


      # Debug

      def dump(io : IO = STDOUT)
        Bytecode.dump(instructions, io)
      end
    end
  end
end
