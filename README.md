# Myst

**A structured, dynamic, general-purpose language.**

```ruby
def fib(0); 1; end
def fib(1); 1; end
def fib(n : Integer)
  fib(n-1) + fib(n-2)
end

[5, 6, 7, 8].map{ |n| fib(n) } #=> [5, 8, 13, 21]
```

Some of the high-level features include:

- **Pattern-matching everywhere.** Assignments, method parameters, rescue clauses, etc.
- **Multiple-clause functions.** All functions can define multiple clauses to adapt functionality based on inputs.
- **Value interpolations.** Interpolate any value anywhere (even in method parameters) with the `<>` syntax.
- **Soft typing.** Optional type annotations help control functionality without cluttering your code with conditionals.
- **Raise anything.** Any value can be raised as an Exception and pattern matched in a rescue block.


# Usage

_NOTE: Due to Crystal's current limitations with compiling on Windows, Myst is only works on macOS and Linux systems._

Myst is currently not deployed to any native package managers, and there are no pre-built binaries, so getting started is a little bit difficult for the time being. No worries, though, there are only a few steps to get started.

First, download a copy of the source code, either through a tagged release, or by [downloading the current master branch](https://github.com/myst-lang/myst/archive/master.zip). Once it's downloaded, unzip it and go to that folder in your terminal.

Now, build the `myst` executable by running `crystal build src/myst.cr` from the root of the folder you downloaded. You should end up with a `myst` executable in that folder. This can be copied anywhere (e.g., `/usr/local/bin`) for your convenience.

To run a program, simply call the executable with a file path as the first argument.

```bash
crystal build src/myst.cr
cp ./myst /usr/local/bin/myst

myst path/to/myst/program
```

Help with improving these usage instructions, making pre-built binaries, and/or managing releases would be greatly appreciated :)


# Roadmap

Progress towards `v0.1.0` is moving steadily. The goal is to have full support for the syntax defined in the original syntax document (with the addition of modules and types), full test coverage of the interpreter internals, and the ability to define tests in the language itself (this will then be the basis of future tests, mainly around the standard library).


# Get Involved

Right now, Myst is a personal project, but I have no intention of keeping it that way! If you have an idea or find a bug, [file an issue for it!](https://github.com/myst-lang/myst/issues/new) If you just want to get involved in the community, [join our Discord server!](https://discord.gg/8FtMeac) Any and all help is appreciated, even if that just means trying out the language for a day!


# Contributing

If you would like to contribute to Myst's development, just:

1. Fork it (https://github.com/myst-lang/myst/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
