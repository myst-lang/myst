# Introduction

Myst is still a small, fledgling language. Help with it's development and growth in any way is greatly appreciated, so here's a thank you in advance :)

This document outlines a few things that will hopefully make your contributions faster, better, and smoother.

While we're glad to receive any contribution that comes our way, there are a few things that are more valuable at this stage in development:

  - Additions to the standard library
  - Documentation
  - Suggestions for an improved syntax
  - General bugfixes
  
That said, please don't use the issue tracker for support questions. The [Myst Language Discord server](https://discord.gg/8FtMeac) is a much better place for those questions as the conversation can move quicker and you'll likely reach a larger audience. Keeping the issue tracker clean also helps organize upcoming work and discussions about the language.

Also, please read our [Code of Conduct](CODE_OF_CONDUCT.md) before submitting your contributions. Doing so will help make the whole process go more smoothly.

# Getting started
If you would like to contribute to Myst's development:

  - Fork it (https://github.com/myst-lang/myst/fork)
  - Create your feature branch (git checkout -b my-new-feature)
  - Commit your changes (git commit -am 'Add some feature')
  - Push to the branch (git push origin my-new-feature)
  - Create a new Pull Request

Small or "obvious" fixes can be rolled in as part of a larger change, but please limit this to just one or two miscellaneous changes. As a rule of thumb, changes are obvious fixes if they do not introduce any new functionality or change the semantics of the language. Likely examples include the following:

  - Spelling / grammar fixes
  - Typo correction, white space and formatting changes
  - Comment clean up
  - Removing debug output
  
If you see multiple of these fixes that you would like to make, please consider making a separate Pull Request with them all bundled together.


# How to report a bug

When filing an issue, make sure to answer these five questions:

1. What version of Myst are you using? (release? master?)
2. What operating system and processor architecture are you using?
3. What did you do?
4. What did you expect to see?
5. What did you see instead?

As mentioned previously, general questions should go in the [Myst Language Discord server](https://discord.gg/8FtMeac) instead of the issue tracker. You're more likely to get a faster, better response there.


# Community

As mentioned above we have a [Myst Language Discord server](https://discord.gg/8FtMeac) for support questions and general discussion about Myst. Feel free to join, even if you don't have any questions.


# Formatting
 
Myst is implemented in Crystal, and generally follows the style guide as enforced by `crystal tool format`. There are some exceptions, and enforcement is lackadaisical, but try to keep that style in mind while writing code.
 
For commit messages, please include the section(s) of the codebase that the commit touches in brackets at the beginning of the commit, as well as a brief summary of the change and/or rationale behind it. For example:

```
[doc,stdlib] Allow multiple arguments to `IO#puts`
`IO#puts` now takes a splat argument, allowing multiple arguments to be passed in. All arguments will be printed consecutively with no separators. After all arguments have been printed, a newline character will be printed as well.
```

Using markdown formatting in commit messages is also appreciated, as some commit viewers are capable of rendering Markdown, creating a nicer experience for those reading.

Please _do not_ use hard word-wrapping (e.g. 80 or 120 characters) in commit messages as it will not display well for users with normal-sized screens, and particularly on phones.
