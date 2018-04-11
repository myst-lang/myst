# This file is for documentation purposes only. The methods defined here
# are implemented as part of the native library of Myst. They are reproduced
# here to allow the documentation generator to include native documentation.

#doc Boolean
#| A Boolean is an object representing either `true` or `false` values. The
#| only way to create new Boolean objects is to use the boolean literals `true`
#| and `false`.
deftype Boolean
  #doc to_s -> string
  #| Returns either `"true"` or `"false"` depending on this Boolean's value.
  def to_s; end

  #doc ==(other) -> boolean
  #| Returns `true` if `other` has the same value as this Boolean (i.e., both
  #| are `true` or both are `false`). If `other` is _not_ a Boolean, this
  #| method will return `false`.
  def ==(other); end

  #doc !=(other) -> boolean
  #| Returns `true` if `other` has any value other than the value of this
  #| Boolean. Only returns `false` if `other` is a Boolean and has the same
  #| value as this Boolean.
  def !=(other); end
end
