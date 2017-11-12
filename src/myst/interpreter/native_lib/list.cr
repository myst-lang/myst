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

    NativeLib.method :list_access_assign, TList, index : TInteger, value : Value do
      this.elements[index.value] = value
    end


    def init_list(kernel : TModule)
      list_type = TType.new("List", kernel.scope)
      list_type.instance_scope["type"] = list_type

      NativeLib.def_instance_method(list_type, :each, :list_each)
      NativeLib.def_instance_method(list_type, :+,    :list_add)
      NativeLib.def_instance_method(list_type, :[],   :list_access)
      NativeLib.def_instance_method(list_type, :[]=,  :list_access_assign)

      list_type
    end
  end
end
