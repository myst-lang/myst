module Myst
  VERSION_MAJOR = 0
  VERSION_MINOR = 3
  VERSION_PATCH = 0
  VERSION_EXTRA = ""
  RELEASE_DATE = "2017-12-28"

  def Myst.version
    String.build do |str|
      str << VERSION_MAJOR
      str << "."
      str << VERSION_MINOR
      str << "."
      str << VERSION_PATCH
      unless VERSION_EXTRA.empty?
        str << "-"
        str << VERSION_EXTRA
      end
    end
  end

  def Myst.verbose_version
    <<-VERSION
    Myst version #{version} (released #{RELEASE_DATE})
    Built on:
    - Crystal: #{Crystal::VERSION} (#{Crystal::BUILD_COMMIT} from #{Crystal::BUILD_DATE})
    - LLVM: #{Crystal::LLVM_VERSION}
    VERSION
  end
end
