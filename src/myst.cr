require "./myst/vm"

vm = Myst::VM::VM.new
vm.load("./spec/bytecode.mtc")
vm.bytecode.dump(STDOUT)
