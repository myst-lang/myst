require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"


private def it_interprets_the_type(source, &block : Myst::TType, Myst::Interpreter ->)
  it "interprets `#{source}`" do
    itr = parse_and_interpret(source)
    _type = itr.stack.pop.as(TType)
    block.call(_type, itr)
  end
end

describe "Interpreter - TypeDef" do
  it_interprets_the_type %q(
    deftype Foo
    end
  ) do |typ, itr|
    typ.should be_a(Myst::TType)
    typ.scope.values.size.should eq(0)
    typ.scope.parent.should eq(itr.current_scope)
  end

  # Functions defined within a type should have their lexical scope set as
  # that type's instance scope.
  it_interprets_the_type %q(
    deftype Foo
      def foo
      end
    end
  ) do |typ, itr|
    typ.instance_scope.has_key?("foo").should be_truthy
    foo = typ.instance_scope["foo"].as(TFunctor)

    foo.lexical_scope.should eq(typ.instance_scope)
  end

  # Static functions defined within a type should have their lexical scope set
  # as that type's class scope.
  it_interprets_the_type %q(
    deftype Foo
      defstatic foo
      end
    end
  ) do |typ, itr|
    typ.scope.has_key?("foo").should be_truthy
    foo = typ.scope["foo"].as(TFunctor)

    foo.lexical_scope.should eq(typ.scope)
  end

  # Defining a function in a type should not make it available outside of
  # the type.
  it_interprets_the_type %q(
    deftype Foo
      def foo
      end
    end
  ) do |typ, itr|
    itr.current_scope["foo"]?.should be_falsey
  end


  # Defining a type more than once in the same scope re-opens the type.
  it_interprets_the_type %q(
    deftype Foo
      def foo; end
    end

    deftype Foo
      def bar; end
    end
  ) do |typ, itr|
    typ.instance_scope.has_key?("foo").should be_truthy
    typ.instance_scope.has_key?("bar").should be_truthy
  end

  # Nesting types have all the same behavior as top-level types
  it_interprets_the_type %q(
    deftype Foo
      deftype Bar
        def foo; end
      end

      deftype Bar
        def bar; end
      end
    end
  ) do |typ, itr|
    bar = typ.scope["Bar"].as(TType)
    bar.instance_scope.has_key?("foo").should be_truthy
    bar.instance_scope.has_key?("bar").should be_truthy
  end

  it_interprets_the_type %q(
    deftype Foo
      deftype Bar
        def foo; end
      end
    end

    deftype Foo
      deftype Bar
        def bar; end
      end
    end
  ) do |typ, itr|
    typ.instance_scope.has_key?("foo").should be_falsey
    typ.instance_scope.has_key?("bar").should be_falsey

    bar = typ.scope["Bar"].as(TType)
    bar.instance_scope.has_key?("foo").should be_truthy
    bar.instance_scope.has_key?("bar").should be_truthy
  end
end
