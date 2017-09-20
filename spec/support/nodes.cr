require "../spec_helper.cr"

include Myst::AST

# Utilities for generating AST Nodes with fewer characters.

# l(value)
#
# Generate a Literal node corresponding to the type of the provided value.
# Calls with Arrays and Hashes act recursively.
def l(value : Node  );  value; end
def l(value : Nil   );  NilLiteral.new;                           end
def l(value : Bool  );  BooleanLiteral.new(value).as(Node);       end
def l(value : Int   );  IntegerLiteral.new(value.to_s).as(Node);  end
def l(value : Float );  FloatLiteral.new(value.to_s).as(Node);    end
def l(value : String);  StringLiteral.new(value).as(Node);        end
def l(value : Symbol);  SymbolLiteral.new(value.to_s).as(Node);   end
def l(value : Array(T)) forall T
  ListLiteral.new(value.map{ |v| (v.is_a?(Node) ? v : l(v)).as(Node) }).as(Node)
end
def l(value : Hash(K, V)) forall K, V
  entries = value.map do |k, v|
    MapLiteral::Entry.new(key: l(k), value: l(v))
  end

  MapLiteral.new(entries).as(Node)
end


# i(value)
#
# Generate a ValueInterpolation node from the given value. If the value is not
# a Node already, it is assumed to be a Literal.
def i(value : Node);  ValueInterpolation.new(value);    end
def i(value);         ValueInterpolation.new(l(value)); end


# v(name)
#
# Generate a Var node with the given name.
def v(name) : Var
  Var.new(name)
end

# c(name)
#
# Generate a Const node with the given name.
def c(name) : Const
  Const.new(name)
end

# u(name)
#
# Generate an Underscore node with the given name.
def u(name) : Underscore
  Underscore.new(name)
end

# p(name=nil, pattern=nil, restriction: nil, splat: false, block: false)
#
# Generate a Param node. The default usage creates a basic Param with only a
# name. Pattern can be given as a second argument, and splat, and block can be
# added with named parameters.
def p(name=nil, pattern=nil, restriction=nil, splat=false, block=false)
  Param.new(pattern: pattern, name: name, restriction: restriction, splat: splat, block: block)
end

# e(*nodes)
#
# Generate an Expressions node from the given nodes.
def e(*nodes : Node)
  Expressions.new(*nodes)
end
