require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"


private def it_interprets_the_module(source, &block : Myst::TModule, Myst::Interpreter ->)
  it "interprets `#{source}`" do
    itr = parse_and_interpret(source)
    _module = itr.stack.pop.as(TModule)
    block.call(_module, itr)
  end
end

describe "Interpreter - ModuleDef" do
  it_interprets_the_module %q(
    module Foo
    end
  ) do |mod, itr|
    mod.should be_a(Myst::TModule)
    mod.scope.values.size.should eq(0)
    mod.scope.parent.should eq(itr.current_scope)
  end

  # Functions defined within a module should have their lexical scope set as
  # that module.
  it_interprets_the_module %q(
    module Foo
      def foo
      end
    end
  ) do |mod, itr|
    mod.scope.has_key?("foo").should be_truthy
    foo = mod.scope["foo"].as(TFunctor)

    foo.lexical_scope.should eq(mod.scope)
  end

  # Defining a function in a module should not make it available outside of
  # the module.
  it_interprets_the_module %q(
    module Foo
      def foo
      end
    end
  ) do |mod, itr|
    itr.current_scope["foo"]?.should be_falsey
  end


  # Defining a module more than once in the same scope re-opens the module.
  it_interprets_the_module %q(
    module Foo
      def foo; end
    end

    module Foo
      def bar; end
    end
  ) do |mod, itr|
    mod.scope.has_key?("foo").should be_truthy
    mod.scope.has_key?("bar").should be_truthy
  end

  # Nesting modules have all the same behavior as top-level modules
  it_interprets_the_module %q(
    module Foo
      module Bar
        def foo; end
      end

      module Bar
        def bar; end
      end
    end
  ) do |mod, itr|
    bar = mod.scope["Bar"].as(TModule)
    bar.scope.has_key?("foo").should be_truthy
    bar.scope.has_key?("bar").should be_truthy
  end

  it_interprets_the_module %q(
    module Foo
      module Bar
        def foo; end
      end
    end

    module Foo
      module Bar
        def bar; end
      end
    end
  ) do |mod, itr|
    mod.scope.has_key?("foo").should be_falsey
    mod.scope.has_key?("bar").should be_falsey

    bar = mod.scope["Bar"].as(TModule)
    bar.scope.has_key?("foo").should be_truthy
    bar.scope.has_key?("bar").should be_truthy
  end
end
