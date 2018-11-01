require "stdlib/spec.mt"

describe("Type") do
  describe(".to_s") do
    it("with a literal") do
      assert({}.type.to_s).equals("Map")
    end

    it("with user defined type") do
      deftype T
      end

      assert(T.to_s).equals("T")
    end

    it("does not include the namespace of the type") do
      defmodule Foo
        deftype Bar
        end
      end

      assert(Foo.Bar.to_s).equals("Bar")
    end
  end


  describe(".==") do
    deftype Type1; end
    deftype Type2; end
    deftype SubType1 : Type1; end
    deftype SubType2 : Type1; end
    defmodule Mod1; end

    it("returns true for the same type") do
      assert(Type1 == Type1).is_true
    end

    it("returns false for different types") do
      assert(Type1 == Type2).is_false
    end

    it("returns false for a type and a subtype") do
      assert(Type1 == SubType1).is_false
    end

    it("returns false for a type and a supertype") do
      assert(SubType1 == Type1).is_false
    end

    it("returns false for different subtypes") do
      assert(SubType1 == SubType2).is_false
    end

    it("returns false for a type and a module") do
      assert(Type1 == Mod1).is_false
    end
  end


  describe(".!=") do
    deftype Type1; end
    deftype Type2; end
    deftype SubType1 : Type1; end
    deftype SubType2 : Type1; end
    defmodule Mod1; end

    it("returns false for the same type") do
      assert(Type1 != Type1).is_false
    end

    it("returns true for different types") do
      assert(Type1 != Type2).is_true
    end

    it("returns true for a type and a subtype") do
      assert(Type1 != SubType1).is_true
    end

    it("returns true for a type and a supertype") do
      assert(SubType1 != Type1).is_true
    end

    it("returns true for different subtypes") do
      assert(SubType1 != SubType2).is_true
    end

    it("returns true for a type and a module") do
      assert(Type1 != Mod1).is_true
    end
  end

  describe(".ancestors") do
    defmodule Foo; end
    defmodule Bar
      include Foo
    end

    deftype RootType; end
    deftype SubType1 : RootType; end
    deftype SubType2 : SubType1
      include Foo
    end
    deftype SubType3 : SubType1
      include Bar
    end
    deftype SubType4 : SubType2; end

    it("returns a List of the supertypes of the type") do
      assert(RootType.ancestors).is_a(List)
    end

    it("does not include the type itself in the resulting list") do
      assert(RootType.ancestors.any?{ |a| a == RootType }).is_false
    end

    it("includes the base Type") do
      assert(RootType.ancestors).includes(Type)
    end

    it("includes the base Object") do
      assert(RootType.ancestors).includes(Object)
    end

    it("includes Object when called on Type") do
      assert(Type.ancestors).equals([Object])
    end

    it("is empty when called on Object") do
      assert(Object.ancestors).equals([])
    end

    it("includes all supertypes of the type") do
      assert(SubType1.ancestors).equals([RootType, Type, Object])
    end

    it("does not include subtypes of the type") do
      assert(RootType.ancestors.any?{ |a| a == SubType1 }).is_false
    end

#    # TODO: Re-add these when Module#== is implemented.
#    it("includes the included modules for the type") do
#      assert(SubType2.ancestors).includes(Foo)
#    end
#
#    it("includes modules included by other included modules") do
#      assert(SubType3.ancestors).includes(Bar)
#      assert(SubType3.ancestors).includes(Foo)
#    end
#
#    it("includes modules includes by supertypes") do
#      assert(SubType4.ancestors).includes(Foo)
#    end
  end
end
