# This file is for documentation purposes only. The methods defined here
# are implemented as part of the native library of Myst. They are reproduced
# here to allow the documentation generator to include native documentation.

#doc doc -> string
#| Returns the documentation attached to the given value as a String.
def doc(value); end

#doc exit(status : Integer) -> no return
#| Immediately exits the program, returning the given status code to the system.
def exit(status : Integer); end
#doc exit -> no return
#| Immediately exits the program with a successful status code (`0`).
def exit; end

#doc sleep(time : Integer) -> nil
#| Causes the program to sleep for `time` seconds.
def sleep(time : Integer); end
#doc sleep(time : Float) -> nil
#| Causes the program to sleep for `time` seconds.
def sleep(time : Float); end
#doc sleep -> nil
#| Causes the program to sleep forever until woken up by an external source.
def sleep; end
