# Myst

**A structured, dynamic, general-purpose language.**

```ruby
deftype List
  def contains(element)
    each(&fn
      ->(<element>) { break true }
      ->(_)         { false }
    end)
  end
end

[1, 2, 3].contains(2) #=> true
```

Some of the high-level features include:

- **Pattern-matching everywhere.** Assignments, method parameters, rescue clauses, etc.
- **Multiple-clause functions.** All functions can define multiple clauses to adapt functionality based on inputs.
- **Value interpolations.** Interpolate any value anywhere (even in method parameters) with the `<>` syntax.
- **Soft typing.** Optional type annotations help control functionality without cluttering your code with conditionals.
- **Raise anything.** Any value can be raised as an Exception and pattern matched in a rescue block.


# Installation

_NOTE: Due to Crystal's current limitations with compiling on Windows, Myst
only works on macOS and Linux systems._

The recommended method of installing Myst is with `mtenv`, the official version manager for the Myst language. It is available [here](https://github.com/myst-lang/mtenv) and has installation instructions available in the README.

For now, you will need to have Crystal installed to be able to install Myst. See [Crystal's installation instructions](https://crystal-lang.org/docs/installation/) for how to get started.

Once Crystal and `mtenv` are installed, installing Myst is as simple as running `mtenv install`:

```shell
# Make sure mtenv is properly set up
mtenv setup
# Install v0.6.0 of Myst
mtenv install v0.6.0
# Make it the active version
mtenv use v0.6.0
```

With that, `myst` should now be installed and ready to go!

Help with improving these installation instructions, making pre-built binaries, and/or managing releases would be greatly appreciated :)


# Get Involved

If you have an idea for a new feature or find a bug in Myst, _please_ [file an issue for it!](https://github.com/myst-lang/myst/issues/new). Using the language and finding bugs are the best ways to help Myst improve. Any and all help here is appreciated, even if that just means trying out the language for a day.

If you just want to get involved in the community, come hang out [in our Discord server!](https://discord.gg/8FtMeac). We're a pretty small community, so there's plenty of room for anyone that would like to hang out, even if it has nothing to do with Myst!

When I can, I try to label issues with [`help wanted`](https://github.com/myst-lang/myst/labels/help%20wanted) or [`good first issue`](https://github.com/myst-lang/myst/labels/good%20first%20issue). [`help wanted`](https://github.com/myst-lang/myst/labels/help%20wanted) is for issues that I'd _really_ like external input on, while [`good first issue`](https://github.com/myst-lang/myst/labels/good%20first%20issue) is for issues that can be implemented without too much knowledge of how the lexer/parser/interpreter works. On these issues, I try to explain as much as possible about what the solution looks like, including files that will need editing and/or methods that need implementing/changing. I hope that helps!

If you'd like to tackle something, but don't know where to start, _please_ let me know! I'd love to help you get involved, so feel free to ask in the [discord server](https://discord.gg/8FtMeac) or message me directly (faulty#7958 on discord, or email also works) and I'll do my best to get you up and running.

### The Basics

If you would like to contribute to Myst's development, just:

1. Fork it (https://github.com/myst-lang/myst/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request (https://github.com/myst-lang/myst/pull/new)

### Owning an issue

If you have a [specific issue](https://github.com/myst-lang/myst/issues) that you'd like to tackle, be sure to add a comment saying you're working on it so that everyone is aware! (currently, github [doesn't allow for assigning issues to new contributers](https://github.com/isaacs/github/issues/100) :/)

Also, "ownership" is _not_ binding. It's just a way of saying "hey, I think I can work on this!". If you get stuck or need help moving forward, feel free to ask for help either on the issue itself, or [in the discord server](https://discord.gg/8FtMeac).

Most importantly, **don't feel bad if you bite off more than you can chew**. Issues can easily end up being far more complex than they appear at the start, especially on a project of this size. But don't give up! It's always hard to get started on an existing project, but I want to help and make it as easy as possible wherever I can!
