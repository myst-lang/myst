# This file is for documentation purposes only. The methods defined here
# are implemented as part of the native library of Myst. They are reproduced
# here to allow the documentation generator to include native documentation.

#doc Integer
#| An Integer is an object representing a 64-bit integer number.
#|
#| New Integer objects are created using integer literals, which are
#| represented as a series of one or more digits. Integer literals may also
#| contain underscore characters between any two digits to improve legibility.
#|
#| The following are all valid integer literals: `000`, `12_345__`, `10_000_00`.
#|
#| The following are not considered integer literals: `1.0`, `1a1`, `abc1`.
deftype Integer
  #doc + -> integer | float
  #| Returns the result of adding the value of `other` to this integer. This
  #| method is only valid when `other` is a float or an integer. Any other type
  #| will cause this method to raise a RuntimeError.
  #|
  #| If `other` is a Float, this method will return a Float instead of an
  #| Integer.
  def +(other); end

  #doc - -> integer | float
  #| Returns the result of subtracting the value of `other` from this integer.
  #| This method is only valid when `other` is a float or an integer. Any other
  #| type will cause this method to raise a RuntimeError.
  #|
  #| If `other` is a Float, this method will return a Float instead of an
  #| Integer.
  def -(other); end

  #doc * -> integer | float
  #| Returns the result of multiplying the value of `other` with this integer.
  #| This method is only valid when `other` is a float or an integer. Any other
  #| type will cause this method to raise a RuntimeError.
  #|
  #| If `other` is a Float, this method will return a Float instead of an
  #| Integer.
  def *(other); end

  #doc / -> integer | float
  #| Returns the result of dividing this integer by the value of `other`.
  #| This method is only valid when `other` is a float or an integer. Any other
  #| type will cause this method to raise a RuntimeError.
  #|
  #| If `other` is a Float, this method will return a Float instead of an
  #| Integer.
  #|
  #| This method will also raise a RuntimeError if the value of `other` would
  #| cause a division by zero.
  def /(other); end

  #doc % -> integer | float
  #| Returns the result of adding the value of `other` to this integer. This
  #| method is only valid when `other` is a float or an integer. Any other type
  #| will cause this method to raise a RuntimeError.
  #|
  #| If `other` is a Float, this method will return a Float instead of an
  #| Integer.
  #|
  #| This method will also raise a RuntimeError if the value of `other` would
  #| cause a division by zero.
  def %(other); end

  #doc to_f -> float
  #| Returns a new Float object with the same value as this integer.
  def to_f; end

  #doc to_s -> string
  #| Returns a new String object representing this integer in base 10. This
  #| method does _not_ preserve underscores from integer literals.
  def to_s; end

  #doc == -> boolean
  #| Returns `true` if `other` has the same value as this integer. This method
  #| considers integer-value Float objects as equal to their Integer
  #| counterparts.
  #|
  #| If `other` is not either a Float or an Integer, this method
  #| will always return `false`.
  def ==(other); end

  #doc != -> boolean
  #| Returns `true` if `other` has any value other than the value of this
  #| float. This method considers integer-value Float objects as equal to their
  #| Integer counterparts.
  #|
  #| If `other` is not either a Float or an Integer, this method will always
  #| return `true`.
  def !=(other); end

  #doc negate -> integer
  #| Returns a new Integer object representing the result of multiplying this
  #| integer's value by `-1`.
  def negate; end

  #doc < -> boolean
  #| Returns `true` if `other` is a Float or an Integer, and has a value that
  #| is mathematically less than this float.
  #|
  #| If `other` is not a Float or an Integer, this method will raise a RuntimeError.
  def <(other); end

  #doc <= -> boolean
  #| Returns `true` if `other` is a Float or an Integer, and has a value that
  #| is mathematically less than or equal to this float.
  #|
  #| If `other` is not a Float or an Integer, this method will raise a RuntimeError.
  def <=(other); end

  #doc > -> boolean
  #| Returns `true` if `other` is a Float or an Integer, and has a value that
  #| is mathematically greater than or equal to this float.
  #|
  #| If `other` is not a Float or an Integer, this method will raise a RuntimeError.
  def >(other); end

  #doc >= -> boolean
  #| Returns `true` if `other` is a Float or an Integer, and has a value that
  #| is mathematically greater than this float.
  #|
  #| If `other` is not a Float or an Integer, this method will raise a RuntimeError.
  def >=(other); end

end
