module Crystal
  class Module
    attr_reader :object_class
    attr_reader :class_class
    attr_reader :nil_class
    attr_reader :bool_class
    attr_reader :number_class
    attr_reader :int_class
    attr_reader :long_class
    attr_reader :float_class
    attr_reader :char_class

    def define_builtin_classes
      define_object_class
      define_class_class
      define_c_class
      define_nil_class
      define_bool_class
      define_number_class
      define_int_class
      define_long_class
      define_float_class
      define_char_class
    end

    def define_object_class
      @object_class = define_class Class.new("Object")
    end

    def define_class_class
      @class_class = Class.new "Class", @object_class
      @class_class.define_static_method :class, Def.new("Class#class", [Var.new("self")], @class_class)
      define_class @class_class
    end

    def define_nil_class
      @nil_class = define_class NilClass.new("Nil", @object_class)
    end

    def define_bool_class
      @bool_class = define_class BoolClass.new("Bool", @object_class)
    end

    def define_number_class
      @number_class = define_class Class.new("Number", @object_class)
    end

    def define_int_class
      @int_class = define_class IntClass.new("Int", @number_class)
    end

    def define_long_class
      @long_class = define_class LongClass.new("Long", @object_class)
    end

    def define_float_class
      @float_class = define_class FloatClass.new("Float", @number_class)
    end

    def define_char_class
      @char_class = define_class CharClass.new("Char", @object_class)
    end

    def define_class(klass)
      add_expression klass
    end
  end

  class Class
    def llvm_type
      LLVM::Int64
    end

    def codegen(mod)
      LLVM::Int64.from_i object_id
    end

    def llvm_cast(value)
      object_id = value.to_i LLVM::Int64.type
      ObjectSpace._id2ref object_id
    end
  end

  class NilClass < Class
    def llvm_type
      LLVM::Type.void
    end

    def llvm_cast(value)
      Nil.new
    end
  end

  class BoolClass < Class
    def llvm_type
      LLVM::Int1
    end

    def llvm_cast(value)
      Bool.new value.to_b
    end
  end

  class IntClass < Class
    def llvm_type
      LLVM::Int32
    end

    def llvm_cast(value)
      Int.new(value.to_i LLVM::Int32.type)
    end
  end

  class LongClass < Class
    def llvm_type
      LLVM::Int64
    end

    def llvm_cast(value)
      Long.new(value.to_i LLVM::Int64.type)
    end
  end

  class FloatClass < Class
    def llvm_type
      LLVM::Float
    end

    def llvm_cast(value)
      Float.new(value.to_f LLVM::Float.type)
    end
  end

  class CharClass < Class
    def llvm_type
      LLVM::Int8
    end

    def llvm_cast(value)
      Char.new(value.to_i LLVM::Int8.type)
    end
  end
end
