require "stdlib/spec.mt"

include Spec
include Spec.DSL

# TODO: add Dir globbing to automatically detect and require all `*_spec.mt`
# files under this directory.
require "./boolean_spec.mt"
require "./enumerable_spec.mt"
require "./float_spec.mt"
require "./integer_spec.mt"
require "./list_spec.mt"
require "./map_spec.mt"
require "./nil_spec.mt"
require "./string_spec.mt"
require "./symbol_spec.mt"
require "./unary_ops/not_spec.mt"
require "./type_spec.mt"
require "./time_spec.mt"

# The only way to reach this point is if all of the Specs passed. Any failures
# will immediately exit the program, so reaching here implies success.
STDOUT.puts("\nAll in-language specs passed.")
