module Myst
  class Interpreter
    # Matches are syntax sugar for the creation and immediate invocation of an
    # anonymous function. As such, they can be re-written into a Call of an
    # AnonymousFunction node. For example:
    #     match x, y
    #       ->(true) { }
    #       ->(false) { }
    #       ->(*_) { }
    #     end
    # would be expanded to
    #     (fn
    #       ->(true) { }
    #       ->(false) { }
    #       ->(*_) { }
    #     end)(x, y)
    # which is semantically equivalent.
    def visit(node : Match)
      visit(
        Call.new(nil,
          name: AnonymousFunction.new(node.clauses, internal_name: "match").at(node),
          args: node.arguments,
          block: nil,
          infix: false
        ).at(node)
      )
    end
  end
end
