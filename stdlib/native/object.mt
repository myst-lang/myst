# This file is for documentation purposes only. The methods defined here
# are implemented as part of the native library of Myst. They are reproduced
# here to allow the documentation generator to include native documentation.

#doc Object
#| `Object` is the base type for every object in Myst. It provides some basic,
#| default behavior for common operations to simplify prototyping of new types
#| and allow algorithms to assume some common ground for all objects in the
#| program.
#|
#| While these implementations do ensure that all objects have _some_ default
#| behavior, subtypes should almost always provide specializations that provide
#| more accurate (and potentially more efficient) behavior.
#|
#| `Object` is automatically added to the ancestry of every type and module,
#| and can also be used as a generic type restriction to explicitly show that a
#| method may accept or return any type of object.
#|
#| **Note:** While `Type` is not part of `Object`s ancestry, it does have
#| access to the static methods defined on `Type` (e.g., `.ancestors` and
#| `.to_s`).
deftype Object
  #doc to_s -> string
  #| Returns a new String with some debug information about the object. This
  #| method should be overridden by any type that wants to serialize its contents.
  def to_s : String; end

  #doc ==(other) -> boolean
  #| Returns `true` only if `other` represents the same object as this object.
  #| Two different instances with the same content will _not_ be considered equal
  #| by this method.
  def ==(other) : Boolean; end

  #doc !=(other) -> boolean
  #| Returns `false` only if `other` represents the same object as this object.
  #| Two different instances with the same content will _not_ be considered equal
  #| by this method.
  def !=(other) : Boolean; end
end
