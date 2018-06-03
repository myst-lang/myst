require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"


private def it_interprets_the_type(source, file=__FILE__, line=__LINE__, end_line=__END_LINE__, &block : Myst::TType, Myst::Interpreter ->)
  it "interprets `#{source}`", file, line, end_line do
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


  # The `self` inside of a type definition is the type itself, so static
  # methods and other properties should be available there.
  it_interprets %q(
    deftype Foo
      defstatic static_method
      end

      static_method
    end
  )



  # Type can provide a supertype to inherit from, which makes all methods
  # and properties from the supertype available to the type itself (similar to
  # composition with `extend` and `include`, but combined into one expression).
  it_interprets_the_type %q(
    deftype Foo
      defstatic static_inherited
        :static_inherited
      end

      def instance_inherited
        :instance_inherited
      end
    end

    deftype Bar : Foo
    end
  ) do |typ, itr|
    itr.recursive_lookup(typ, "static_inherited").should be_a(TFunctor)
    itr.recursive_lookup(TInstance.new(typ), "instance_inherited").should be_a(TFunctor)
  end

  # Type paths can also be given as supertypes and act the same way.
  it_interprets_the_type %q(
    deftype Foo
      deftype Bar
        defstatic static_inherited
          :static_inherited
        end

        def instance_inherited
          :instance_inherited
        end
      end
    end

    deftype Baz : Foo.Bar
    end
  ) do |typ, itr|
    itr.recursive_lookup(typ, "static_inherited").should be_a(TFunctor)
    itr.recursive_lookup(TInstance.new(typ), "instance_inherited").should be_a(TFunctor)
  end

  # Finally, the supertype can be given as an interpolation that resolves to
  # a TType value.
  it_interprets_the_type %q(
    deftype Foo
      defstatic static_inherited
        :static_inherited
      end

      def instance_inherited
        :instance_inherited
      end
    end

    type_to_inherit_from = Foo

    deftype Baz : <type_to_inherit_from>
    end
  ) do |typ, itr|
    itr.recursive_lookup(typ, "static_inherited").should be_a(TFunctor)
    itr.recursive_lookup(TInstance.new(typ), "instance_inherited").should be_a(TFunctor)
  end

  # Inheritance is transitive (A < B < C implies A < C).
  it_interprets_the_type %q(
    deftype Foo
      def instance_inherited
        :instance_inherited
      end
    end

    deftype Bar : Foo
    end

    deftype Baz : Bar
    end
  ) do |typ, itr|
    itr.recursive_lookup(TInstance.new(typ), "instance_inherited").should be_a(TFunctor)
  end

  # The supertype definition _must_ resolve to a TType.
  it_does_not_interpret %q(
    deftype Foo : <nil>
    end
  )
  it_does_not_interpret %q(
    Bar = "Hello"
    deftype Foo : Bar
    end
  )

  # Inheritance can only be specified on the first definition of a type.
  # Re-opening the type and specifying inheritance will cause an error.
  it_does_not_interpret %q(
    deftype Foo; end
    deftype Bar : Foo; end
    # This definition will fail, because Bar already exists. Even though the
    # supertype is the same, it will still fail.
    deftype Bar : Foo; end
  )

  # All types automatically inherit from `Type`.
  it_interprets_the_type %q(
    deftype Foo; end
  ) do |typ, itr|
    typ.ancestors.map(&.name).should eq(["Type", "Object"])
  end
  # When inheriting another type, it is prepended to the ancestor list
  it_interprets_the_type %q(
    deftype Foo : Integer; end
  ) do |typ, itr|
    typ.ancestors.map(&.name).should eq(["Integer", "Type", "Object"])
  end
end
