require "../value"

module Myst::Kernel
  extend self

  def puts(arguments : Array(Value))
    arguments.each{ |arg| puts arg }
    return TNil.new.as(Value)
  end

  add_kernel_method :puts, 1
end
