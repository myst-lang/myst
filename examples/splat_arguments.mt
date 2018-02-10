# Functions can define "splat collectors" as parameters. These parameters will
# gather any positional arguments that are not explicitly matched and make them
# available under the given name.
#
# Splat collectors accept 0 or more arguments, meaning a function whose only
# parameter is a splat collector can accept 0 or more arguments. If no
# arguments for the splat collector are provided, it's value will be an empty
# List.
def splats(*args)
  i = 0
  STDOUT.puts("args to `splats`:")
  args.each() do |arg|
    i = i + 1
    STDOUT.puts("  Arg " + i.to_s() + ": " + arg.to_s())
  end
end

splats()
splats("a")
splats("a", "b")
splats("a", "b", "c", "d", "e")


# Splat collectors can be mixed anywhere among other positional arguments, but
# only one collector may be used in a function definition. Where Ruby, Crystal,
# and other splat-collecting languages only allow splats as the last positional
# parameter, Myst allows the splat collector to be defined anywhere in the
# list of positional parameters.
#
# For example, the following function returns the last argument passed to it,
# no matter how many arguments are passed. However, because the function
# defines an explicit positional parameter (`last`), it will not match calls
# with no parameters.
def head_of(head, *_)
  head
end

def tail_of(*_, last)
  last
end

def h_and_t(head, *_, tail)
  [head, tail]
end


STDOUT.puts(head_of("a", "b", "c", "d"))  #=> a
STDOUT.puts(head_of("a"))                 #=> a
STDOUT.puts(tail_of("a", "b", "c", "d"))  #=> d
STDOUT.puts(tail_of("a"))                 #=> a
STDOUT.puts(h_and_t("a", "b", "c", "d"))  #=> [a, d]
STDOUT.puts(h_and_t("a", "b"))            #=> [a, b]

