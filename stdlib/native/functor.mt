# This file is for documentation purposes only. The methods defined here
# are implemented as part of the native library of Myst. They are reproduced
# here to allow the documentation generator to include native documentation.

#doc Functor
#| A Functor is an object representing a group of function clauses under the
#| same name. Every function/method in Myst is stored as a Functor.
#|
#| Calling a Functor (generally referred to as "invoking" the Functor), will
#| attempt to match the given arguments with the parameters of each clause,
#| in the order that the clauses were added to the Functor. If no match is
#| found, a `NoMatchingClause` RuntimeError is raised.
deftype Functor
  #doc to_s -> string
  #| Returns a String object with the name of this functor and the number of
  #| clauses it contains. The string will have the format `&<name>/<clauses>`.
  #|
  #| This method is mainly intended for debugging purposes where the name of
  #| the Functor may be useful. It is _not_ a serialization of the Functor.
  def to_s
  end
end
