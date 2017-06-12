require "./myst/vm"

include Myst::VM

iseq = InstructionSequence.new
iseq.add_instruction(Instruction::Push.new(MTValue.new("Hello,")))
iseq.add_instruction(Instruction::Push.new(MTValue.new(" world!")))
iseq.add_instruction(Instruction::Add.new)
iseq.add_instruction(Instruction::Write.new)

File.open("./generated_bytecode.mtc", "w") do |io|
  iseq.to_bytecode(io)
end
