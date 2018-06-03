# This file is for documentation purposes only. The methods defined here
# are implemented as part of the native library of Myst. They are reproduced
# here to allow the documentation generator to include native documentation.

#doc Float
#| A Float is an object representing a 64-bit floating point number, as defined
#| by IEEE 754.
#|
#| New Float objects are created using float literals, which are represented as
#| a series of one or more digits, a dot, and another series of one or more
#| digits. Float literals may also contain underscore characters between any
#| two digits to improve legibility.
#|
#| The following are all valid float literals: `0.0`, `123.456`, `10_000.00_000`.
#|
#| The following are not considered float literals: `.0`, `1.`, `1.2.3`.
deftype Float
  #doc + -> float
  #| Returns the result of adding the value of `other` to this float. This
  #| method is only valid when `other` is a float or an integer. Any other type
  #| will cause this method to raise a RuntimeError.
  def +(other : Integer) : Float; end
  def +(other : Float) : Float; end

  #doc - -> float
  #| Returns the result of subtracting the value of `other` from this float.
  #| This method is only valid when `other` is a float or an integer. Any other
  #| type will cause this method to raise a RuntimeError.
  def -(other : Integer) : Float; end
  def -(other : Float) : Float; end

  #doc * -> float
  #| Returns the result of multiplying the value of `other` with this float. This
  #| method is only valid when `other` is a float or an integer. Any other type
  #| will cause this method to raise a RuntimeError.
  def *(other : Integer) : Float; end
  def *(other : Float) : Float; end

  #doc / -> float
  #| Returns the result of dividing this float by the value of `other`. This
  #| method is only valid when `other` is a float or an integer. Any other type
  #| will cause this method to raise a RuntimeError.
  #|
  #| This method will also raise a RuntimeError if the value of `other` would
  #| cause a division by zero.
  def /(other : Integer) : Float; end
  def /(other : Float) : Float; end

  #doc % -> float
  #| Returns the remainder of the result of dividing this float by the value of
  #| `other`. This method is only valid when `other` is a float or an integer.
  #| Any other type will cause this method to raise a RuntimeError.
  #|
  #| This method will also raise a RuntimeError if the value of `other` would
  #| cause a division by zero.
  def %(other : Integer) : Float; end
  def %(other : Float) : Float; end

  #doc to_i -> integer
  #| Returns the integer portion of this float as a new Integer object by
  #| truncating the decimal portion from the value. As such, this method will
  #| always "round down" to the largest integer not greater than this value.
  def to_i : Integer; end

  #doc round -> integer
  #| Returns a new Integer object representing the integer that is nearest to
  #| the value of this float. This method considers `.5` decimals nearer to the
  #| upper integer.
  def round : Integer; end

  #doc to_s -> string
  #| Returns a new String object representing this float in base 10. This
  #| method does _not_ preserve underscores from float literals.
  def to_s : String; end

  #doc == -> boolean
  #| Returns `true` if `other` has the same value as this float. This method
  #| considers integer-value Float objects as equal to their Integer
  #| counterparts.
  #|
  #| If `other` is not either a Float or an Integer, this method
  #| will always return `false`.
  def ==(other) : Boolean; end

  #doc != -> boolean
  #| Returns `true` if `other` has any value other than the value of this
  #| float. This method considers integer-value Float objects as equal to their
  #| Integer counterparts.
  #|
  #| If `other` is not either a Float or an Integer, this method will always
  #| return `true`.
  def !=(other) : Boolean; end

  #doc negate -> float
  #| Returns a new Float object representing the result of multiplying this
  #| float's value by `-1`.
  def negate : Float; end

  #doc < -> boolean
  #| Returns `true` if `other` is a Float or an Integer, and has a value that
  #| is mathematically less than this float.
  #|
  #| If `other` is not a Float or an Integer, this method will raise a RuntimeError.
  def <(other : Integer) : Boolean; end
  def <(other : Float) : Boolean; end

  #doc <= -> boolean
  #| Returns `true` if `other` is a Float or an Integer, and has a value that
  #| is mathematically less than or equal to this float.
  #|
  #| If `other` is not a Float or an Integer, this method will raise a RuntimeError.
  def <=(other : Integer) : Boolean; end
  def <=(other : Float) : Boolean; end

  #doc > -> boolean
  #| Returns `true` if `other` is a Float or an Integer, and has a value that
  #| is mathematically greater than or equal to this float.
  #|
  #| If `other` is not a Float or an Integer, this method will raise a RuntimeError.
  def >(other : Integer) : Boolean; end
  def >(other : Float) : Boolean; end

  #doc >= -> boolean
  #| Returns `true` if `other` is a Float or an Integer, and has a value that
  #| is mathematically greater than this float.
  #|
  #| If `other` is not a Float or an Integer, this method will raise a RuntimeError.
  def >=(other : Integer) : Boolean; end
  def >=(other : Float) : Boolean; end
end
