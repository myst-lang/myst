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
      JUMP        # JUMP n|l - Jump to instruction n or the one labeled l.

      # DEBUG
      PRINT_STACK

      def modifies_program_counter?
        [JUMP].includes?(self)
      end
    end


    struct Instruction
      property type : InstructionType
      property args : Array(String)

      def initialize(comm : String, @args=[] of String)
        @type = InstructionType.parse(comm)
      end

      def initialize(@type : InstructionType, @args=[] of String); end

      def to_s
        "#{type}\t#{args.join(' ')}"
      end

      def to_s(io : IO)
        io << to_s
      end

      def modifies_program_counter?
        type.modifies_program_counter?
      end
    end
  end
end
