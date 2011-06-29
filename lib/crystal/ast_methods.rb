module Crystal
  class ASTNode
    def self.find_method(name)
      nil
    end
  end

  class Intrinsic < Def
    def initialize(name, arg_types, resolved_type, &block)
      @name = name
      @args = arg_types.each_with_index.map { |type, i| Var.new("x#{i}", type) }
      @resolved_type = resolved_type
      @block = block
    end

    def codegen_body(mod, fun)
      @block.call mod, fun
    end
  end

  class Class
    def self.name
      super.split("::")[-1]
    end

    def self.to_s;
      name
    end

    def self.crystal_define_method(name, method)
      @methods[name] = method
    end

    def self.crystal_define_intrinsic(name, arg_types, resolved_type, &block)
      @methods[name] = Intrinsic.new("#{self.name}##{name}", arg_types, resolved_type, &block)
    end

    def self.find_method(name)
      method = @methods[name]
      method ? method.dup : nil
    end
  end

  class Bool
    @methods = {}
    crystal_define_method 'class', Def.new("Bool#class", [Var.new("self")], Int.new(object_id))
    crystal_define_intrinsic(:'==', [Bool, Bool], Bool) { |mod, fun| mod.builder.icmp :eq, fun.params[0], fun.params[1], 'eqtmp' }
  end

  class Int
    @methods = {}
    crystal_define_method 'class', Def.new("Int#class", [Var.new("self")], Int.new(object_id))
    crystal_define_method :'+@', Def.new("Int#+@", [Var.new("self")], Ref.new("self"))
    crystal_define_method :'-@', Def.new("Int#-@", [Var.new("self")], Call.new(Int.new(0), :'-', Ref.new("self")))
    crystal_define_intrinsic(:'+', [Int, Int], Int) { |mod, fun| mod.builder.add fun.params[0], fun.params[1], 'addtmp' }
    crystal_define_intrinsic(:'-', [Int, Int], Int) { |mod, fun| mod.builder.sub fun.params[0], fun.params[1], 'subtmp' }
    crystal_define_intrinsic(:'*', [Int, Int], Int) { |mod, fun| mod.builder.mul fun.params[0], fun.params[1], 'multmp' }
    crystal_define_intrinsic(:'/', [Int, Int], Int) { |mod, fun| mod.builder.sdiv fun.params[0], fun.params[1], 'sdivtmp' }
    crystal_define_intrinsic(:'<', [Int, Int], Bool) { |mod, fun| mod.builder.icmp :slt, fun.params[0], fun.params[1], 'slttmp' }
    crystal_define_intrinsic(:'<=', [Int, Int], Bool) { |mod, fun| mod.builder.icmp :sle, fun.params[0], fun.params[1], 'sletmp' }
    crystal_define_intrinsic(:'>', [Int, Int], Bool) { |mod, fun| mod.builder.icmp :sgt, fun.params[0], fun.params[1], 'sgttmp' }
    crystal_define_intrinsic(:'>=', [Int, Int], Bool) { |mod, fun| mod.builder.icmp :sge, fun.params[0], fun.params[1], 'sgetmp' }
    crystal_define_intrinsic(:'==', [Int, Int], Bool) { |mod, fun| mod.builder.icmp :eq, fun.params[0], fun.params[1], 'eqtmp' }
  end
end
