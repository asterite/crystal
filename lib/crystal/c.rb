module Crystal
  class Module
    def define_c_class
      klass = add_expression Class.new("C", @object_class, CMetaclass.new(self))
    end

    def add_c_expression(node)
      @expressions["#{node.name}"] = node
    end

    def find_c_expression(name)
      @expressions[name]
    end
  end

  class CMetaclass < Class
    def initialize(mod)
      @mod = mod
      @name = "C"
    end

    def find_method(name)
      @mod.find_c_expression name
    end
  end
end
