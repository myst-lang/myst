module Myst
  struct Callstack
    record Entry,
      location : Location?,
      name : String?

    property context : Array(Entry)

    def initialize(@context = [] of Entry)
    end

    def to_s(io : IO)
      context.reverse_each do |c|
        location = c.location.try(&.to_s(colorize: true))
        # colorize special names
        name =
          case n = c.name
          when "raise"
            n.colorize(:red)
          when "rescue", "ensure"
            n.colorize(:green)
          else
            n
          end.to_s

        case {name, location}
        when {String, String}
          io << "  in `#{name}` at #{location}\n"
        when {nil, String}
          io << "  at #{location}\n"
        when {String, nil}
          io << "  in `#{name}` (no location info available)\n"
        when {nil, nil}
          io << "  at an unknown frame\n"
        else
          puts typeof(name)
          puts typeof(location)
        end
      end
    end

    def push(entry : Entry)
      @context.push(entry)
    end

    def push(location : Location?, name : String?=nil)
      @context.push(Entry.new(location, name))
    end

    def [](index)
      @context[index]
    end

    def []?(index)
      @context[index]?
    end

    def []=(index, value : Entry)
      @context[index] = value
    end

    delegate first, last, size, reverse_each, pop, to: context
  end
end
