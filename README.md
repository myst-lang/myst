# Myst

**A practical, dynamic language.** The primary goals of the language are:

- **Be easy to understand:** Avoid special characters wherever possible. Expressions should flow in syntax as they do in thought. Don't surprise the user. Developers with a background in Ruby, Elixir, Crystal, or other similar languages should feel right at home, though feature parity with any of these is not a goal.
- **Be reasonably fast:** Myst is a straight-forward, interpreted language, so it should be expected to perform competitively with similar established languages like Python and Ruby, and comparably with others like Elixir. It's okay to trade flexibility for performance.

More goals are sure to come as the language develops, but these are the driving points for now.


# Roadmap

The following is a roadmap for a `v0.1.0` of Myst. It is _not necessarily_ comprehensive of the original [Syntax document](SYNTAX.md), but should provide the basis of a usable scripting language. As time goes on, this roadmap may be further refined and modified.

- [X] Values
  - [X] booleans
  - [X] floats
  - [X] functors
  - [X] integers
  - [X] lists
  - [X] maps
  - [X] nativefunctors
  - [X] nils
  - [X] strings
  - [X] symbols
- [ ] Flow control and dependency loading
  - [X] `if`/`unless`/`elif`/`else`
  - [X] `while`/`until`
  - [ ] `break`
  - [ ] `return`
  - [ ] `next`
  - [X] `require`
  - [ ] `case`/`cond` for sequential conditions
- [X] Functions/blocks
  - [X] positional parameters
  - [X] pattern matches
  - [X] multiple definitions/clause-based lookup
  - [X] type restrictions
  - [X] positional splat collectors
  - [X] explicit block parameters
- [ ] Modules
  - [X] reopening
  - [X] nested definitions
  - [ ] `include` other modules
- [X] Decomposition/pattern matching
  - [X] variable bindings
  - [X] value interpolations
  - [X] variable re-use (via interpolation)
  - [X] splat collectors
  - [X] list patterns
  - [X] map patterns
- [ ] Standard Library
  - [ ] IO
  - [ ] File
  - [ ] Dir
  - [ ] Math
  - [ ] Enumerable

The standard library will likely expand before a `0.1.0` is released. Another goal for `0.1.0` is 60+% test coverage, primarily at a feature test level.


# Get Involved

Right now, Myst is a personal project, but I have no intention of keeping it that way! If you have an idea or find a bug, [file an issue for it!](https://github.com/myst-lang/myst/issues/new) If you just want to get involved in the community, [join our Discord server!](https://discord.gg/8FtMeac) Any and all help is appreciated, even if that just means trying out the language for a day!


# Contributing

If you would like to contribute to Myst's development, just:

1. Fork it (https://github.com/myst-lang/myst/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
