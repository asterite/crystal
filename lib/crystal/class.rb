module Crystal
  class Class
    attr_accessor :class_class

    def initialize(name, superclass = nil)
      @name = name
      @superclass = superclass
      @methods = {}
    end

    def root
      root = self
      root = root.superclass while root.superclass
      root
    end

    def metaclass
      @metaclass ||= Metaclass.new self
    end

    def subclass_of?(other)
      self == other || @superclass == other
    end

    def define_method(method)
      method.obj = self if method.respond_to? :obj
      @methods[method.name] = method
    end

    def find_method(name)
      method = @methods[name]
      if method
        method.dup
      else
        @superclass ? @superclass.find_method(name) : nil
      end
    end
  end

  class Metaclass < Class
    def initialize(a_class)
      @class = a_class
      @methods = {}
    end

    def class_class
      @class.root.class_class
    end

    def find_method(name)
      method = @methods[name]
      if method
        method.dup
      else
        if @class.superclass
          @class.superclass.metaclass.find_method name
        else
          class_class.find_method name
        end
      end
    end

    def subclass_of?(other)
      class_class.subclass_of? other
    end

    def llvm_type(mod)
      class_class.llvm_type(mod)
    end

    def name
      @class.name
    end

    def resolved_type
      self
    end

    def to_s
      name
    end
  end
end
