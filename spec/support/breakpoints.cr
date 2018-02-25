# This file defines ways of pausing execution of Myst code to allow specs to
# make assertions while running, rather than waiting until afterward. This is
# especially helpful for testing things like `self` values, scoping, and
# callstack management, where after execution the respective stacks for these
# values will be empty.
require "../spec_helper.cr"

# Add a special method to the Kernel of the given interpreter that runs the
# given handler block when encountered in a program. This method will be
# available like any normal method in Myst, and can accept any arbitrary set
# of parameters for testing. See `NativeLib.method` for more details.
#
# The handler block will have three variables made available:
#   - A `this` parameter representing `self` at the time of the call
#   - An `__args` parameter representing the normal arguments to the call
#   - A `block` parameter representing the optional block argument
#
# Example:
#
#   itr = Interpreter.new
#   add_breakpoint(itr, "breakpoint") do |this, args, block|
#     args[0].should be_a(Int64)
#   end
#
#   parse_and_interpret %q(
#     [1, 2, 3].each do |e|
#       breakpoint(e)
#     end
#   ), interpreter: itr
macro add_breakpoint(itr, name)
  %handler = ->(this : MTValue, __args : Array(MTValue), block : TFunctor?) do
    %result = begin
      {{ yield }}
    end

    %result.is_a?(MTValue) ? %result : TNil.new.as(MTValue)
  end

  {{itr}}.kernel.scope[{{name}}] = TFunctor.new({{name}}, [%handler] of Callable)
end
