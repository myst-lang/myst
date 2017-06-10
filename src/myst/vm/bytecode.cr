module Myst
  module VM
    module Bytecode
      extend self

      def from_file(file_name : String) : Array(Instruction)
        instruction_buffer = [] of Instruction
        File.open(file_name) do |io|
          io.each_line do |line|
            args = line.split(' ')
            inst = Instruction.new(args[0])
            inst.args = args[1..-1] if args.size > 1
            instruction_buffer << inst
          end
        end

        instruction_buffer
      end


      # Return the instructions in this buffer in a String format suitable for
      # writing to a file.
      def dump(instructions : Array(Instruction))
        String.build{ |str| dump(str) }
      end

      # Write the instructions in this buffer in a String format into `io`.
      def dump(instructions : Array(Instruction), io : IO)
        instructions.each do |inst|
          io << inst << "\n"
        end
      end
    end
  end
end
