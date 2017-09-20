module Myst
  # This module is responsible for managing the dependency tree of a Myst
  # program. It manages the files that have already been loaded and decides
  # whether or not a given file can/should be loaded.
  #
  # The result of any of the methods defined here is either an `AST::Node`
  # as the entry point into the requested file's code, or `nil` if the file
  # was not loaded (was already loaded, etc.). `load` will _always_ return an
  # `AST::Node` if the file can be resolved (the result will not be nilable).
  #
  # If a given file _cannot_ be loaded (file doesn't exist, path is not valid),
  # these methods will raise the appropriate errors.
  module DependencyLoader
    extend self

    def load_dirs
      @@load_dirs ||= begin
        if paths = ENV["MYST_LOAD_DIRS"]?
          paths.split(':')
        else
          # Until Myst is distributed as a binary and meant to be installable
          # as a global command, just the execution's local path will be
          # considered as a load path.
          [Dir.current]
        end
      end
    end

    def already_loaded
      @@already_loaded ||= {} of String => Bool
    end

    def require(path_value, working_dir)
      path = resolve_path(path_value, working_dir)
      unless already_loaded[path]?
        already_loaded[path] = true
        Parser.for_file(path).parse
      end
    end

    def load(path_value, working_dir)
      path = resolve_path(path_value, working_dir)
      already_loaded[path] = true
      Parser.for_file(path).parse
    end


    # Ensure that the given path resolves to a valid file and can be loaded.
    # The result of this method will always be a String to use directly in
    # a `File.read`.
    private def resolve_path(path, working_dir) : String
      # Only String paths are valid, so if the given path is not a String value,
      # raise an error about it.
      unless path.is_a?(TString)
        raise "Path for `require` must be a String, got #{path}"
      end

      path_string = path.value

      # Relative paths should be considered as-is. Absolute and bare paths
      # should consider all variants based on the current `load_dirs` that
      # are available.
      if is_relative?(path_string)
        path_string = File.expand_path(path_string, dir: working_dir)
        validate_path(path_string)
      else
        load_dirs.each do |dir|
          expanded_path_string = File.expand_path(path_string, dir: dir)
          if validate_path(expanded_path_string)
            path_string = expanded_path_string
          end
        end
      end

      return path_string
    end


    # Validate that the given path resolves to a real, readable file. Return
    # false if that is not true.
    private def validate_path(full_path)
      unless File.exists?(full_path) && File.readable?(full_path)
        raise "File '#{full_path}' is not available (unreadable or does not exist)."
      end
      false
    end

    private def is_relative?(path)
      path.starts_with?("./") || path.starts_with?("../")
    end
  end
end
