require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

# For simplicity with relative paths, set the current working directory to the
# directory of this file for the duration of these tests.
Dir.cd(__DIR__) do
  describe "Interpreter - Require" do
    # When a `require` is successful, it will return true.
    it_interprets %q(
      require "./require_support/bar_defs.mt"
    ),                  [val(true)]

    # When a `require` is _not_ successful, it raises an error.
    it_does_not_interpret %q(
      require "./a/file/that/doesnt/exist.mt"
    )

    # If a file has already been required, but would have otherwise been
    # successful, it will return false.
    it_interprets %q(
      require "./require_support/bar_defs.mt"
      require "./require_support/bar_defs.mt"
    ),                  [val(false)]

    # A files "loaded" status is determined by its absolute path. Using an
    # alternate path for the same file should now load it again.
    it_interprets %q(
      require "./require_support/bar_defs.mt"
      require "./require_support/../require_support/bar_defs.mt"
    ),                  [val(false)]

    # `require` executes the code from the file within the scope that the
    # `require` appeared.
    it_interprets %q(
      require "./require_support/baz_module.mt"
      require "./require_support/bar_defs.mt"
      [Baz.baz, bar, bar(1, 2)]
    ),                  [val([:baz, nil, 3])]

    # Paths starting with `./` or `../` are considered relative paths and lookup
    # is performed relative to the file that the `require` occurs in.
    it_interprets %q(
      require "../../support/requirable/foo_defs.mt"
    ),                  [val(true)]


    it "allows variables for as a path" do
      itr = parse_and_interpret %q(
        path = "../../support/requirable/foo_defs.mt"
        require path
      )

      itr.stack.pop.should eq(val(true))
    end

    it "allows complex expressions as a path" do
      itr = parse_and_interpret %q(
        dir = "../../support/requirable/"
        file = "foo_defs.mt"
        require dir + file
      )

      itr.stack.pop.should eq(val(true))
    end

    it "must be given a String value as a path" do
      expect_raises do
        itr = parse_and_interpret %q(
          require true
        )
      end
    end

    it "properly follows directories for nested requires" do
      itr = parse_and_interpret %q(
        require "./require_support/nested_require.mt"
        bar(1, 2)
      )

      itr.stack.pop.should eq(val(3))
    end
  end
end
