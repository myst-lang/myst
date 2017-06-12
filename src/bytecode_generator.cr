require "./myst/vm"

include Myst::VM

iseq = InstructionSequence.new
iseq.add_instruction(Instruction::Push.new(MTValue.new(1_i64)))
iseq.add_instruction(Instruction::SetLocal.new(MTValue.new("n_2")))
iseq.add_instruction(Instruction::Push.new(MTValue.new(1_i64)))
iseq.add_instruction(Instruction::SetLocal.new(MTValue.new("n_1")))
iseq.add_instruction(Instruction::Label.new(MTValue.new("loop")))
iseq.add_instruction(Instruction::GetLocal.new(MTValue.new("n_1")))
iseq.add_instruction(Instruction::GetLocal.new(MTValue.new("n_2")))
iseq.add_instruction(Instruction::Add.new)
iseq.add_instruction(Instruction::Dup.new)
iseq.add_instruction(Instruction::Write.new)
iseq.add_instruction(Instruction::GetLocal.new(MTValue.new("n_1")))
iseq.add_instruction(Instruction::SetLocal.new(MTValue.new("n_2")))
iseq.add_instruction(Instruction::SetLocal.new(MTValue.new("n_1")))
iseq.add_instruction(Instruction::Jump.new(MTValue.new("loop")))

File.open("./generated_bytecode.mtc", "w") do |io|
  iseq.to_bytecode(io)
end
