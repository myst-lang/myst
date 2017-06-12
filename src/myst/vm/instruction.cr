require "./instruction/*"

module Myst
  module VM
    module Instruction
      # Nop is the base class of all instructions

      # Variables
      def_instruction GetLocal,     0x01,
        name : MTValue
      def_instruction SetLocal,     0x02,
        name : MTValue

      # Stack
      def_instruction Push,         0x10,
        value : MTValue
      def_instruction Pop,          0x11
      def_instruction Dup,          0x12
      def_instruction DupN,         0x13,
        size : MTValue

      # Math
      def_instruction Add,          0x20
      def_instruction Subtract,     0x21
      def_instruction Multiply,     0x22
      def_instruction Divide,       0x23
      def_instruction Power,        0x24
      def_instruction Negate,       0x25

      # Comparison
      def_instruction Equal,        0x30
      def_instruction NotEqual,     0x31
      def_instruction LessThan,     0x32
      def_instruction LessEqual,    0x33
      def_instruction GreaterEqual, 0x34
      def_instruction GreaterThan,  0x35

      # Logic
      def_instruction And,          0x40
      def_instruction Or,           0x41
      def_instruction Not,          0x42

      # Flow
      def_instruction Label,        0x50,
        name : MTValue
      def_instruction Jump,         0x51,
        target : MTValue
      def_instruction JumpIf,       0x52,
        target : MTValue
      def_instruction JumpUnless,   0x53,
        target : MTValue

      # Transform
      def_instruction BuildArray,   0x80,
        size : MTValue
      def_instruction BuildMap,     0x81
        size : MTValue
      def_instruction Splat,        0x90

      # IO
      def_instruction Write,        0xa0


      # Create an Instruction parser based on the instructions defined above.
      def_parser
    end
  end
end
