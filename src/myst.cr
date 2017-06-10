require "./myst/vm"

source_file = ARGV[0]?

unless source_file
  STDERR.puts("No source file given")
  exit 1
end

vm = Myst::VM::VM.new
vm.load(source_file)
vm.dump(STDOUT)
vm.run
