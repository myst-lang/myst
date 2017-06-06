module Myst
  module VM
    class BytecodeBuffer
      property instructions : Array(Instruction)

      def self.from_file(file_name : String)
        file = File.open(file_name)
        buffer = BytecodeBuffer.new(file)
        file.close
        buffer
      end


      def initialize(io : IO)
        @instructions = [] of Instruction

        io.each_line do |line|
          args = line.split(' ')
          inst = Instruction.new(args[0])
          inst.args = args[1..-1] if args.size > 1
          @instructions << inst
        end
      end

      def initialize
        @instructions = [] of Instruction
      end


      # Concatenate the bytecode from `other` onto this buffer.
      def append(other : BytecodeBuffer)
        instructions.concat(other.instructions)
      end


      # Return the instructions in this buffer in a String format suitable for
      # writing to a file.
      def dump
        String.build{ |str| dump(str) }
      end

      # Write the instructions in this buffer in a String format into `io`.
      def dump(io : IO)
        instructions.each do |inst|
          io << inst << "\n"
        end
      end
    end
  end
end
