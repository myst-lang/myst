require "./myst/vm"

source_file = ARGV[0]?

unless source_file
  STDERR.puts("No source file given")
  exit 1
end

vm = Myst::VM::VM.new
vm.load_isequence(source_file)
# Dump instruction sequence
vm.isequences[source_file].disasm(STDOUT)
vm.run
