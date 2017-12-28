# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## v0.3.0

### Additions
- Many additions to the standard library (See #57. Thanks @bmulvihill, @minirop, @atuley, and @zkayser). `Integer`, `Float`, and `Enumerable` received big buffs, among other things.
- Added a `Time` type and `Time#now` to get the current system time (see #85. Thanks, @bmulvihill).
- Added the `extend` keyword for adding Module ancestors to the static scope of a Type (see #77. Thanks, @zkayser).
- Added support for the Splat operator (`*`) for deconstructing objects into Lists of values (see #71).
- Added support for Unary operators Not (`!`) and Negation (`-`) (see #52, #46. Thanks, @rainbru).
- Allow any functor to be "captured" with the `&` unary operator (see #50).
- Added support for anonymous functions using the `fn` keyword (see #47).
- Object instantiations can accept captured functions as the block parameter (See #91). This keeps parity with regular method calls.
- Added `__FILE__`, `__LINE__`, and `__DIR__` magic constants (see #90, #45. Thanks, @bmulvihill).

### Bug Fixes
- Properly maintain local scope overrides after rescuing an error (see #95).
- Properly restore the value `self` after rescuing an error (see #65).
- Fixed a bug with `List#==` where lists were incorrectly considered equal (see #89. Thanks, @bmulvihill).
- Open angle brackets in Strings no longer cause a `ParseError` (see #80. Thanks, @bmulvihill).
- Accessing/assigning non-existent elements in a List no longer raises an error (see #72. Thanks, @bmulvihill).

### Miscellaneous
- Adding parentheses after a `Var` will always force it to be a `Call`, even with no arguments (see #54. Thanks, @bmulvihill).

### Infrastructure
- Upgraded to Crystal 0.24.1 (see #99). This should improve the experience of developing Myst, particularly on macOS.
- Fixed the fibonnaci example code to use the correct sequence numbers in the comments (see #55. Thanks, @minirop).



## v0.2.0

### Added

- Interpolate any expression into a string using `<(...)>` (#33)
- Add operational assignments (e.g., `||=` and `+=`) for shorter, cleaner expressions (#30)
- Allow operators as method names (#29)
- Query and bang (`?` and `!`) methods (#28)
- Warning messages when referencing Underscore variables (#34. Thanks, @rainbru!)
- `self` returns the interpreter's current `self` value (#40)
- Basic Spec library for making assertions in Myst code (#39)


### Bug fixes

- Fixed Constant lookup from instances to also check the static scope (#38)


### Miscellaneous

- Better linux installation instructions (#32. Thanks, @rainbru!)



## v0.1.0

Initial release of the Myst language!
