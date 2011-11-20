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
    attr_reader :c_class

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
      define_c_class
      define_static_array_class
    end

    def define_object_class
      @object_class = define_class Class.new("Object")
      @object_class.define_method Def.new('initialize', [], nil)
    end

    def define_class_class
      @class_class = define_class Class.new("Class", @object_class)
      @class_class.define_method Def.new('new', [], nil)
      @object_class.class_class = @class_class
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

    def define_c_class
      @c_class = define_class Class.new("C", @object_class)
    end

    def define_static_array_class
      @static_array_class = define_class StaticArrayClass.new("StaticArray", @object_class, [Var.new("T")])
      @static_array_class.metaclass.define_method Def.new('new', [Var.new('size')], static_array_new)
      @static_array_class.define_method Def.new(:'[ ]', [Var.new('index')], static_array_get)
      @static_array_class.define_method Def.new(:'[]=', [Var.new('index'), Var.new('value')], static_array_set)
    end

    def define_class(klass)
      @classes[klass.name] = klass
    end

    private

    def static_array_new
      exps = Parser.parse("If size.class != Int; static_array_new_size_must_be_int; End")
      exps.expressions << NewStaticArray.new
      exps
    end

    def static_array_get
      exps = Parser.parse("If index.class != Int; static_array_get_index_must_be_int; End")
      exps.expressions << StaticArrayGet.new
      exps
    end

    def static_array_set
      exps = Parser.parse("If index.class != Int; static_array_set_index_must_be_int; End If value.class != T; static_array_set_value_must_be_T; End")
      exps.expressions << StaticArraySet.new
      exps
    end
  end

  class Class
    def llvm_type(mod)
      LLVM::Int64
    end

    def codegen(mod)
      LLVM::Int64.from_i object_id
    end

    def llvm_cast(value)
      object_id = value.to_i LLVM::Int64.type
      ObjectSpace._id2ref object_id
    end

    def instance_llvm_type(mod)
      @instance_llvm_type ||= begin
                                type = LLVM::Type.struct @vars.values.map { |x| x.type.resolved.llvm_type(mod) }, false
                                mod.module.types.add "#{@name}", type
                                type
                              end
    end

    def byte_size(mod)
      8
    end
  end

  class NilClass < Class
    def llvm_type(mod)
      LLVM::Type.void
    end

    def llvm_cast(value)
      Nil.new
    end

    def codegen_default(mod)
      nil
    end

    def default_value
      Nil.new
    end

    def byte_size(mod)
      0
    end
  end

  class BoolClass < Class
    def llvm_type(mod)
      LLVM::Int1
    end

    def llvm_cast(value)
      Bool.new value.to_b
    end

    def codegen_default(mod)
      LLVM::Int1.from_i 0
    end

    def default_value
      Bool.new false
    end

    def byte_size(mod)
      1
    end
  end

  class IntClass < Class
    def llvm_type(mod)
      LLVM::Int32
    end

    def llvm_cast(value)
      Int.new(value.to_i LLVM::Int32.type)
    end

    def codegen_default(mod)
      LLVM::Int 0
    end

    def default_value
      Int.new '0'
    end

    def byte_size(mod)
      4
    end
  end

  class LongClass < Class
    def llvm_type(mod)
      LLVM::Int64
    end

    def llvm_cast(value)
      Long.new(value.to_i LLVM::Int64.type)
    end

    def default_value
      Long.new '0'
    end

    def byte_size(mod)
      8
    end
  end

  class FloatClass < Class
    def llvm_type(mod)
      LLVM::Float
    end

    def llvm_cast(value)
      Float.new(value.to_f LLVM::Float.type)
    end

    def codegen_default(mod)
      LLVM::Float 0.0
    end

    def default_value
      Float.new '0.0'
    end

    def byte_size(mod)
      4
    end
  end

  class CharClass < Class
    def llvm_type(mod)
      LLVM::Int8
    end

    def llvm_cast(value)
      Char.new(value.to_i LLVM::Int8.type)
    end

    def codegen_default(mod)
      LLVM::Int8.from_i 0
    end

    def default_value
      Char.new 0
    end

    def byte_size(mod)
      1
    end
  end

  class StaticArrayClass < Class
    def llvm_type(mod)
      LLVM::Pointer(args[0].resolved_type.llvm_type(mod))
    end

    def llvm_cast(value)
      "#{args[0].resolved_type}[?]"
    end

    def default_value
      Nil.new
    end

    def byte_size(mod)
      1
    end
  end

  class InstantiatableClass < Class
    def llvm_type(mod)
      @llvm_type ||= begin
                       struct_types = @instance_vars.keys.sort.map{|key| @instance_vars[key].resolved_type.llvm_type(mod)}
                       LLVM::Pointer(LLVM::Struct(*struct_types))
                     end
    end

    def byte_size(mod)
      sum = 0
      @instance_vars.values.each do |value|
        sum += value.resolved_type.byte_size(mod)
      end
      sum
    end

    def llvm_cast(value)
      "#<#{self.name}>"
    end

    def default_value
      Nil.new
    end
  end
end
