module Myst
  class Interpreter
    NativeLib.method :list_each, TList do
      if block
        this.elements.each do |elem|
          NativeLib.call_func(self, block, [elem], nil)
        end
      end

      this
    end

    NativeLib.method :list_add, TList, other : TList do
      TList.new(this.elements + other.elements)
    end

    NativeLib.method :list_access, TList, index : TInteger do
      this.elements[index.value]
    end


    def init_list(root_scope : Scope)
      list_type = TType.new("List", root_scope)

      NativeLib.def_instance_method(list_type, :each, :list_each)
      NativeLib.def_instance_method(list_type, :+,    :list_add)
      NativeLib.def_instance_method(list_type, :[],   :list_access)

      list_type
    end
  end
end
