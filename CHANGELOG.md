# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

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
