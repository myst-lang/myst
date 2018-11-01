# This file is for documentation purposes only. The methods defined here
# are implemented as part of the native library of Myst. They are reproduced
# here to allow the documentation generator to include native documentation.

#doc Time
#| A Time object is a representation of a specific moment in time.
#|
#| This object stores times as two independent values: the number of full
#| seconds since the Unix Epoch, and the number of nanoseconds after those
#| seconds.
deftype Time
  #doc now -> time
  #| Create and return a new Time object using the current system time.
  defstatic now : Time; end

  #doc to_s(format : String) -> string
  #| Returns a new String using the given `format` string to determine the
  #| content. `format` can contain any combination of the directives listed
  #| here: https://crystal-lang.org/api/0.24.2/Time/Format.html.
  def to_s(format : String) : String; end
  #doc to_s -> string
  #| Renders the string using the default Unix timestamp format.
  def to_s : String; end
end
