# Require statements function similarly to Ruby. They use the same syntax, but
# the behavior is slightly different. In Myst, any path starting with `./` or
# `../` is treated as a file-relative path (the equivalent of Ruby's
# `require_relative`). All other paths will be searched for in the directories
# defined in the `MYST_LOAD_DIRS` environment variable.
#
# `require`s act as simple extensions to the current file. Their contents are
# essentially copy-pasted in place into the current file (most similar to the
# `#include` directive in Cs pre-processor). Unlike Ruby (but more like
# Python), this allows `requires` inside of modules/functions to operate on the
# current scope, rather than the global scope. In essence, `require` in Myst
# can be utilized to both `require` and `include` code into a scope in a single
# statement.

# If this example lives at `examples/require.mt`, the following `require` will
# attempt to load `examples/modules.mt`.
require "./examples/modules.mt"

# The `modules` file loaded above defines an `IO` module, which is now
# available in the current scope.
IO.write("calling required module method")


# Requiring a file inside of a module will import the contents into that scope.
# The following imports the `IO` module defined in `./modules.mt` into the
# `Scoped` module. This is useful for preventing global namespace pollution.
module Scoped
  require "./examples/functions.mt"
end

Scoped.func(1, 2)


# The path for a require can also be determined by any expression that
# evaluates to a String value.
base_path = "./examples/"
path_to_load = "functions.mt"
require base_path + path_to_load
