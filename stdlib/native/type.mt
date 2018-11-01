# This file is for documentation purposes only. The methods defined here
# are implemented as part of the native library of Myst. They are reproduced
# here to allow the documentation generator to include native documentation.

#doc Type
#| `Type` is the base type for all types in Myst. It provides default
#| implementations for common operations on types, such as getting the type
#| name, comparing with other types, and accessing the list of ancestors.
#|
#| Type is a subtype of Object, though all of the functionality of Object is
#| specialized by this type
deftype Type
  #doc to_s -> string
  #| Returns the original name given to this type as a String.
  defstatic to_s : String; end

  #doc ==(other) -> boolean
  #| Returns `true` if `other` represents the same Type as this type.
  defstatic ==(other) : Boolean; end

  #doc !=(other) -> boolean
  #| Returns `false` if `other` represents the same Type as this type.
  defstatic !=(other) : Boolean; end

  #doc ancestors -> list
  #| Returns a flat list of supertypes, included modules, and extended modules
  #| for this type. This list will _always_ contain the base `Type`, but will
  #| _not_ contain the original type itself.
  defstatic ancestors : List; end
end
