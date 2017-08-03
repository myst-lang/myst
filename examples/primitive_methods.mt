# All primitives support method calls directly on themselves, exactly as is
# done in Ruby. Most of these methods are optimized as NativeFunctors to
# improve their execution performance, as they are likely to be some of the
# most frequently called functions.
_mt_write(0, 1 .to_s() + "\n")
_mt_write(0, "hello world".split()[1] + "\n")
