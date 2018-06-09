# Prelude
#
# This file is responsible for loading the core of the standard library into
# the environment for the program being executed. While native APIs are all
# included by default when the interpreter itself is compiled, most of the
# standard library exists as Myst code, and thus is _not_ natively part of
# the interpreter, so it must be loaded when the runtime is started.
#
# Note that the prelude does not include the _entire_ standard library. Rather,
# it includes the most commonly used modules that most (if not all) programs
# will use constantly.

require "./enumerable.mt"
require "./file.mt"
require "./integer.mt"
require "./io.mt"
require "./list.mt"
require "./map.mt"
require "./range.mt"
require "./string.mt"
require "./time.mt"
require "./env.mt"
