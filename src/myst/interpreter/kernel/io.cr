require "../value"

module Myst::Kernel
  extend self

  def puts(arguments : Array(Value), io : IO = STDOUT)
    arguments.each do |arg|
      io.puts(arg)
    end
  end
end
