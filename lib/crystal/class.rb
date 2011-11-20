module Crystal
  class Class
    attr_accessor :class_class
    attr_accessor :superclass
    attr_accessor :args
    attr_accessor :methods
    attr_reader :instance_vars

    def initialize(name, superclass = nil, args = nil)
      @name = name
      @superclass = superclass
      @args = args || []
      @instance_vars = {}
      @methods = {}
    end

    def root
      root = self
      root = root.superclass while root.superclass
      root
    end

    def args_length
      args.length
    end

    def metaclass
      @metaclass ||= Metaclass.new self
    end

    def metaclass=(metaclass)
      @metaclass = metaclass
    end

    def find_instance_var(name)
      @instance_vars[name]
    end

    def define_instance_var(var)
      @instance_vars[var.name] = var
    end

    def subclass_of?(other)
      self == other || @superclass == other
    end

    def define_method(method)
      @methods[method.name] = method
    end

    def find_method(name)
      method = @methods[name]
      if method
        m = method.dup
        m.obj = self if method.respond_to? :obj
        m
      else
        @superclass ? @superclass.find_method(name) : nil
      end
    end

    def to_s
      if @instance_vars.empty?
        @name
      else
        str = "#{@name}"
        str << "<"
        @instance_vars.keys.sort.each_with_index do |key, i|
          str << ', ' unless i == 0
          var = @instance_vars[key]
          str << key
          str << ":"
          str << var.resolved_type.to_s
        end
        str << ">"
        str
      end
    end
  end

  class Metaclass < Class
    def initialize(a_class)
      @class = a_class
      @methods = {}
    end

    def real_class
      @class
    end

    def class_class
      @class.root.class_class
    end

    def find_method(name)
      method = @methods[name]
      if method
        m = method.dup
        m.obj = self if method.respond_to? :obj
        m
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
      "Class"
    end

    def resolved_type
      self
    end

    def to_s
      "#{@class.name}:Class"
    end
  end
end
