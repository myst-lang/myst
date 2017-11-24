# Myst

**A structured, dynamic, general-purpose language.**

```ruby
def fib(0); 0; end
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


# Installation

_NOTE: Due to Crystal's current limitations with compiling on Windows, Myst 
only works on macOS and Linux systems._

### macOS

The distribution of Myst is currently maintained through a custom homebrew tap at https://github.com/myst-lang/homebrew-tap.

Installation is pretty simple - you don't even have to add the tap if you don't want to:

```bash
# If you're okay with adding the tap:
brew tap myst-lang/tap
brew install myst-lang

# Or, if you would rather not add the tap:
brew install myst-lang/tap/myst-lang
```

And that's it! You should now have a `myst` executable in your `$PATH` that can be used anywhere.

### Linux/without `brew`

There is currently no native package manager solution for Myst on linux systems. Instead, you'll need to build and install the binary manually. Luckily it's not too complicated.

_Note that you'll need `crystal` installed for the build to succeed. This dependency is automatically managed on macOS._ To install `crystal`, follow these steps :

	# apt-get install dirmngr
	# curl https://dist.crystal-lang.org/apt/setup.sh | bash
	# apt-get install crystal

Now, install `myst`. `cd` to your prefered root dir, then :

First, download the [latest release](https://github.com/myst-lang/myst/releases/latest) or the development (master) reposirtory :

	$ wget https://github.com/myst-lang/myst/archive/v0.1.0.tar.gz
	or
	$ wget https://github.com/myst-lang/myst/archive/master.tar.gz

then untar it somewhere and go to the extracted directory

	```
	$ tar xvf v0.1.0.tar.gz
	or 
	$ tar xvf master.tar.gz
	
	$ cd myst-0.1.0/
	$ shards build
	```

This will give you a `bin` folder with a `myst` executable inside of it. Now, there are two options:

1. Simply add the bin/ directory to your PATH environment variable at the end
   of your *~/.bash_profile* file :

		export PATH="$PATH:/path/to/bin/myst"

  Then, update your current profile using the `source ~/.bashrc` command.

2. The second option is to create a symlink from `/usr/local/bin` or some other folder on your `$PATH` to the `bin` folder that `shards build` generated.

  ```
  ln -s /path/to/bin/myst /usr/local/bin/myst
  ```
  
3. The third option is to move the entire Myst folder to a folder on your `$PATH`. The executable needs to be in a folder that is a sibling to the `stdlib` folder at the root of this project. For example:

  ```
  root
  |- bin
  |  |- myst
  |- stdlib
  |  |- enumerable.mt
  |  |- ...
  |  |- prelude.mt
  ```

  As long as this structure is maintained, the executable should work as expected. Otherwise, you will see an error along the lines of "No file or directory `stlib/prelude.mt`". Full instructions TBD.

Help with improving these installation instructions, making pre-built binaries, and/or managing releases would be greatly appreciated :)


# Get Involved

So far, Myst has been a personal project, but I have no intention of keeping it that way! If you have an idea or find a bug, [file an issue for it!](https://github.com/myst-lang/myst/issues/new) If you just want to get involved in the community, [join our Discord server!](https://discord.gg/8FtMeac) Any and all help is appreciated, even if that just means trying out the language for a day.

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
