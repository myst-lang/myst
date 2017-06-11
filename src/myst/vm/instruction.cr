require "./instruction/*"

module Myst
  module VM
    module Instruction
      def_instruction Nop,      0x00

      def_instruction GetLocal, 0x01,
        name : StringLiteral

      def_instruction SetLocal, 0x02,
        name : StringLiteral

      def_instruction Push,     0x10,
        value : ValueLiteral

      def_instruction Pop,      0x11


      def_parser
    end
  end
end
