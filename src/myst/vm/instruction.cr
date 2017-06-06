module Myst
  module VM
    enum InstructionType
      # Stack operations
      PUSH        # PUSH x - Push x onto the stack

      # Data operations
      LOAD        # LOAD x - Push the value of x onto the stack.
      STORE       # STORE x - Pop a value from the stack into x.

      # Arithmetic operations
      ADD         # ADD - Add two values off the stack and push the result.
      SUBTRACT    # ...
      MULTIPLY    # ...
      DIVIDE      # ...

      # Flow control
      LABEL       # LABEL name - Insert a jumpable label with the given name.
      JUMP        # JUMP x|l - Jump to instruction x or the one labeled l.
    end


    struct Instruction
      property command : InstructionType
      property args : Array(String)

      def initialize(comm : String, @args=[] of String)
        @command = InstructionType.parse(comm)
      end

      def initialize(@command : InstructionType, @args=[] of String); end

      def to_s
        "#{command}\t#{args.join(' ')}"
      end

      def to_s(io : IO)
        io << to_s
      end
    end
  end
end
