module Crystal
  class Class
    def initialize(name, superclass = nil, type = nil)
      @name = name
      @superclass = superclass
      @type = type
      @methods = {}
    end

    def subclass_of?(other)
      self == other || @superclass == other
    end

    def find_method(name)
      method = @methods[name]
      if method
        method.dup
      else
        @superclass ? @superclass.find_method(name) : nil
      end
    end

    def define_method(name, method)
      @methods[name] = method
    end

    def define_static_method(name, method, superclass)
      @type ||= Class.new("Class", superclass, self)
      @type.define_method name, method
    end
  end
end
