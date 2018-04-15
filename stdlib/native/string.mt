# This file is for documentation purposes only. The methods defined here
# are implemented as part of the native library of Myst. They are reproduced
# here to allow the documentation generator to include native documentation.

#doc String
#| A String represents an arbitrary sequence of UTF-8 characters. New String
#| objects are created using String literals, which are character sequences
#| contained within doublequotes (`"`).
#|
#| Special characters can be included a string using backslash escape sequences
#| such as `\n` for a newline character, `\t` for a tab character, or `\0` for
#| a null-terminator.
#|
#| Strings can also include "interpolations", which are Myst expressions that
#| automatically get evaluated, converted to a String value, and then inserted
#| at that position in the string. Interpolations are done with a variant of
#| the global interpolation syntax: `"<()>"`. Unlike interpolations elsehwhere
#| in Myst, the parentheses are always required here to help avoid unnecessary
#| escaping in strings containing `<` and/or `>` characters.
deftype String
  #doc +(other : String) -> string
  #| Returns a new String object with the content of `other` appended after the
  #| content of this string.
  def add(other : String); end

  #doc *(scale : Integer) -> string
  #| Returns a new String object with the content of this string repeated
  #| `scale` times.
  def multiply(scale : Integer); end

  #doc to_i(base : Integer) -> integer
  #| Attempts to parse the content of this string into an integer value,
  #| assuming the value is written using the given `base`.
  #|
  #| If the conversion to an Integer fails for any reason, this method will
  #| raise a RuntimeError.
  def to_i(base : Integer); end
  #doc to_i -> integer
  #| Same as above, but assuming a base 10 representation.
  def to_i; end

  #doc to_f -> float
  #| Attempts to parse the content of this string into a float value, assuming
  #| a base 10 representation.
  #|
  #| If the conversion to a Float fails for any reason, this method will raise
  #| a RuntimeError.
  def to_f; end

  #doc to_s -> self
  #| Returns this string.
  def to_s; end

  #doc ==(other) -> boolean
  #| Returns `true` if `other` is also a String with the same content as this
  #| string. Returns `false` otherwise.
  def ==(other); end

  #doc !=(other) -> boolean
  #| Returns `false` if `other` is also a String with the same content as this
  #| string. Returns `true` otherwise.
  def !=(other); end

  #doc split(delimiter : String) -> list
  #| Returns a new List created by scanning this string for occurrences of
  #| `delimiter` and making a new String from the content between each
  #| occurrence. The occurrences of `delimiter` will _not_ be included in the
  #| resulting list.
  def split(delimiter : String); end
  #doc split -> list
  #| Same as above, but defaulting the delimiter to `" "`.
  def split; end

  #doc size -> integer
  #| Returns the number of unicode codepoints contained in this string. Note
  #| that this is not _necessarily_ the same as the number of bytes in the
  #| string.
  def size; end

  #doc chars -> list
  #| Returns a List of the individual characters in the content of this string.
  #| If this string is empty, the return value will be an empty list.
  def chars; end

  #doc downcase -> string
  #| Return a copy of this string with all uppercase characters converted to
  #| their lowercase counterparts.
  def downcase; end

  #doc upcase -> string
  #| Return a copy of this string with all lowercase characters converted to
  #| their uppercase counterparts.
  def upcase; end

  #doc chomp(suffix : String) -> string
  #| Returns a copy of this string with the given suffix removed from the end
  #| of the content. If the string does not contain the suffix, an unmodified
  #| copy of the string is returned.
  def chomp(suffix : String); end
  #doc chomp -> string
  #| Returns a copy of this string with the last newline/carriage-return
  #| removed. If the string ends with multiple newlines/carriage-returns, only
  #| the last occurrence will be removed, though the special case `\r\n` will
  #| be completely removed.
  def chomp; end

  #doc strip -> string
  #| Returns a copy of this string with all leading and trailing whitespace
  #| removed.
  def strip; end

  #doc rstrip -> string
  #| Returns a copy of this string with all trailing whitespace removed.
  def rstrip; end

  #doc lstrip -> string
  #| Returns a copy of this string with all leading whitespace removed.
  def lstrip; end

  #doc includes?(other : String) -> boolean
  #| Returns true if this string contains the content of `other` anywhere in
  #| its content.
  def includes?(other : String); end

  #doc at(index : Integer, length : Integer) -> string
  #| Returns a new String containing the `length` characters at and after
  #| position `index` in this string.
  def at(index : Integer, length : Integer); end

  #doc reverse -> string
  #| Returns a copy of this string with the order of the characters reversed.
  def reverse; end
end
