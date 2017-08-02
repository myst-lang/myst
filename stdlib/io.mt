STDIN  = 0
STDOUT = 1
STDERR = 2

def puts(arg)
  _mt_write(STDOUT, arg)
  _mt_write(STDOUT, "\n")
end

puts("Hello")
