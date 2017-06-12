require "./instruction/*"

module Myst
  module VM
    module Instruction
      # Nop is the base class of all instructions

      # Variables
      def_instruction GetLocal, 0x01,
        name : MTValue
      def_instruction SetLocal, 0x02,
        name : MTValue

      # Stack
      def_instruction Push,     0x10,
        value : MTValue
      def_instruction Pop,      0x11

      # Math
      def_instruction Add,      0x20
      def_instruction Subtract, 0x21
      def_instruction Multiply, 0x22
      def_instruction Divide,   0x23
      def_instruction Power,    0x24
      def_instruction Negate,   0x25

      # IO
      def_instruction Write,    0xa0


      # Create an Instruction parser based on the instructions defined above.
      def_parser
    end
  end
end
