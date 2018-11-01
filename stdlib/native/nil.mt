# This file is for documentation purposes only. The methods defined here
# are implemented as part of the native library of Myst. They are reproduced
# here to allow the documentation generator to include native documentation.

#doc Nil
#| Nil is a singleton object normally used to represent that a value is not
#| present. The Nil object can be accessed using the nil literal: `nil`.
#|
#| Even though Nil does not represent a real value, the type still implements
#| some basic methods to make dealing with nil easier.
#|
#| Usage of `nil` is generally discouraged in favor of explicitly handling
#| the absence of a value immediately, either by raising an error or providing
#| a default.
deftype Nil
  #doc to_s -> string
  #| Returns the string object `"nil"`.
  def to_s : String; end

  #doc == -> boolean
  #| Returns `false` unless `other` is also the value `nil`.
  def ==(other) : Boolean; end

  #doc != -> boolean
  #| Returns `true` unless `other` is also the value `nil`.
  def !=(other) : Boolean; end
end
