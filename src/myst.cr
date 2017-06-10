require "./myst/vm"

vm = Myst::VM::VM.new
vm.load("./spec/fibonnaci.mtc")
vm.dump(STDOUT)
vm.run
