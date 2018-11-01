# This file is for documentation purposes only. The methods defined here
# are implemented as part of the native library of Myst. They are reproduced
# here to allow the documentation generator to include native documentation.

#doc Map
#| A Map is a dynamically-sized, un-ordered collection of key-value pairs.
deftype Map
  #doc each -> self
  #| Iterate the key-value pairs of this Map. On each iteration, call `block`
  #| with the key and value of that pair as the arguments.
  #|
  #| Returns the original, unmodified Map after completion.
  def each : Map; end

  #doc size -> integer
  #| Returns the number of entries contained in this Map as an integer.
  def size : Integer; end

  #doc +(other) -> map
  #| Returns a new Map object with the key-value pairs of `other` added to this
  #| map. If this map and `other` both contain the a given key, it will be
  #| given the value from `other`.
  def +(other : Map) : Map; end

  #doc ==(other) -> boolean
  #| Returns `true` if `other` is also a Map, has the same number entries,
  #| and the key and value of each entry in `other` are equal to some key-value
  #| pair in this Map.
  #|
  #| If `other` is not a Map, or if any of those conditions are not met, this
  #| method will return `false`.
  def ==(other) : Boolean; end

  #doc !=(other) -> boolean
  #| Returns `false` only if `other` is also a Map, has the same number entries,
  #| and the key and value of each entry in `other` are equal to some key-value
  #| pair in this Map.
  #|
  #| If `other` is not a Map, or if any of those conditions are not met, this
  #| method will return `true`.
  def !=(other) : Boolean; end

  #doc [] -> value?
  #| Returns the value of the entry in this map with the given `key`. If this
  #| map does not have an entry with the given `key`, this method will return
  #| nil instead.
  def [](key); end

  #doc []= -> value
  #| Assigns or creates an entry in this map under `key` with the given `value`.
  #| If this map previously contained an entry under the given `key`, its value
  #| will be overwritten.
  #|
  #| This method returns `value` to be usable in chained expressions.
  def []=(key, value); end

  #doc <(other) -> boolean
  #| Returns `true` if this map is a proper subset of `other`. That is, if
  #| every key-value pair of this map is also present in `other`, _and_ `other`
  #| also contains at least one other entry.
  def <(other : Map) : Boolean; end

  #doc <=(other -> boolean
  #| Returns `true` if this map is a subset of `other`. That is, if every
  #| key-value pair of this map is also present in `other`. `other` does not
  #| have to contain any other entries.
  def <=(other : Map) : Boolean; end
end
