# This file is for documentation purposes only. The methods defined here
# are implemented as part of the native library of Myst. They are reproduced
# here to allow the documentation generator to include native documentation.

#doc IO
#| IO is the base type for all IO types in Myst.
#|
#| Types that inherit this type only need to implement the `read` and `write`
#| methods. From there, this type provides a number of methods for performing
#| complex interactions with input and output streams.
#|
#| By providing a consistent interface for all IO operations in Myst, this type
#| abstracts out the implementation details of interacting with various types
#| of streams and allows users to easily write flexible methods that can work
#| with any input or output object.
deftype IO
  #doc read -> string
  #| This method must be overridden by types that inherit from IO.
  #|
  #| Reads `size` bytes from the underlying stream and returns them as a single
  #| String object. The exact semantics regarding errors is dependent on the
  #| implementing type.
  def read(size : Integer) : String; end

  #doc write -> nil
  #| This method must be overridden by types that inherit from IO.
  #|
  #| Writes the byte representation of `content` to the underlying stream. This
  #| method is generally best used by providing a String value to write.
  #|
  #| The exact semantics regarding errors is dependent on the implementing type.
  def write(content) : Nil; end
end
