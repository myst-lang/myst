# Myst

Myst is a practical dynamic language designed from experience, rather than research. The primary goals of the language are:

- **Be easy to understand:** Avoid special characters wherever possible. Expressions should flow in syntax as they do in thought. Don't surprise the user. Developers with a background in Ruby, Elixir, Crystal, or other similar languages should feel right at home, though feature parity with any of these is not a goal.
- **Be reasonably fast:** Myst compiles to bytecode<sup>1</sup>, so it should be expected to perform competitively with established languages like Python and Ruby, and comparably with others like Elixir. It's okay to trade flexibility for performance.
- **Be extendable:** The compiler should be easy for users to extend. Flexibility like LISP is not a goal, but users should be able to interact with the compiler and/or VM via a direct API, rather than hacks.

More goals are sure to come as the language develops, but these are the driving points for now.

<sup>1</sup> For now, Myst is purely interpreted using a tree-walker. This is slower, but faster for initial development. Once a working interpreter exists, developing the appropriate bytecode will be much simpler.

# Roadmap

At this point, there isn't much of a roadmap for Myst other than what is laid out in the [Syntax document](SYNTAX.md). Once a working language with basic features (simple functions, control flow, all value types) is ready, a more defined roadmap of the remaining features will be made.


# Get Involved

Right now, Myst is a personal project, but I have no intention of keeping it that way! If you have an idea or find a bug, [file an issue for it!](https://github.com/myst-lang/myst/issues/new) If you just want to get involved in the community, [join our Discord server!](https://discord.me/myst) Any and all help is appreciated, even if that just means trying out the language for a day!


# Contributing

If you would like to contribute to Myst's development, just:

1. Fork it (https://github.com/myst-lang/myst/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
