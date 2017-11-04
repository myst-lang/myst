module Myst
  class Interpreter
    # A Hash of entries indicating files that have already been loaded. Entries
    # in this Hash should always be absolute paths to avoid ambiguity between
    # relative paths that resolve to the same file.
    property loaded_files = {} of String => Bool

    def visit(node : Require)
      visit(node.path)
      path = stack.pop

      # The path for a require must be a String, otherwise, the require cannot
      # be successful.
      unless path.is_a?(TString)
        raise "Path for `require` must be a String. Got #{path}"
      end

      path_str = path.value


      # The working directory for the require is always the directory of the
      # file that contains the `require` node being interpreted.
      working_dir =
        if loc = node.location
          File.dirname(loc.file)
        else
          raise "Location information is not available for #{node.inspect}"
        end

      full_path = resolve_path(path_str, working_dir)
      # If the file has already been loaded, return false.
      if @loaded_files[full_path]?
        stack.push(TBoolean.new(false))
        return
      end

      @loaded_files[full_path] = true

      required_source = Parser.for_file(full_path).parse
      visit(required_source)

      # Visiting the required code will leave the last expression's result on
      # the stack. Instead, the return value of a `require` should be either
      # `true` or `false`, so it must be replaced.
      @stack.pop
      @stack.push(TBoolean.new(true))
    end


    # The set of directories that should be considered when performing lookups
    # with bare paths (not explicitly relative).
    def load_dirs
      @load_dirs ||= begin
        paths = [] of String
        # Use any specified environment paths first.
        if env_paths = ENV["MYST_PATH"]?
          paths.concat(env_paths.split(':'))
        end
        paths.concat([
          # Then add the current working directory.
          Dir.current,
          # Finally, the directory where the executable is installed. This is
          # not _guaranteed_ on all systems, but support is good enough, so a
          # non-nil assertion is made.
          #
          # This assumes that the executable exists under a `bin/` folder. The
          # path added here will be the directory that contains `bin`.
          #
          # This is needed to locate the stdlib.
          File.dirname(File.dirname(File.join(Process.executable_path.not_nil!)))
        ])

        paths
      end.as(Array(String))
    end


    # Ensure that the given path resolves to a valid file and can be loaded.
    # The result of this method will always be a String to use directly in
    # a `File.read`.
    private def resolve_path(path : String, working_dir) : String
      # Relative paths should be considered as-is. Absolute and bare paths
      # should consider all variants based on the current `load_dirs` that
      # are available.
      if is_relative?(path)
        path = File.expand_path(path, dir: working_dir)
        validate_path(path)
      else
        load_dirs.find do |dir|
          expanded_path = File.expand_path(path, dir: dir)
          if validate_path(expanded_path)
            path = expanded_path
          end
        end
      end

      return path
    end


    # Return a boolean indicating whether the given path resolves to a real,
    # readable file.
    private def validate_path(full_path)
      File.exists?(full_path) && File.readable?(full_path)
    end

    private def is_relative?(path)
      path.starts_with?("./") || path.starts_with?("../")
    end
  end
end
