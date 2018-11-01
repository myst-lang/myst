# This file is for documentation purposes only. The methods defined here
# are implemented as part of the native library of Myst. They are reproduced
# here to allow the documentation generator to include native documentation.

#doc Symbol
#| A Symbol is a string-like, constant value that gives a name to a unique
#| integer. Every usage of the same symbol in a program will resolve to the
#| same backing object. Since that backing object is an integer, comparisons
#| with Symbols are very efficient.
#|
#| Because of this, Symbols are the default key-types for Maps, and are best
#| used when there is a strict set of expected values (e.g. like an Enum).
deftype Symbol
  #doc to_s -> string
  #| Returns the name used to identify this symbol as a String.
  def to_s : String; end

  #doc ==(other) -> boolean
  #| Returns `true` if `other` is the same Symbol as this symbol.
  def ==(other) : Boolean; end

  #doc !=(other) -> boolean
  #| Returns `false` if `other` is the same Symbol as this symbol.
  def !=(other) : Boolean; end
end
