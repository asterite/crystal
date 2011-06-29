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

  class Bool
    def self.name; "Bool"; end
    def self.to_s; name; end
  end

  class Int
    def self.name; "Int"; end
    def self.to_s; name; end

    Methods = {}
    def self.crystal_define_method(name, method)
      Methods[name] = method
    end

    def self.crystal_define_intrinsic(name, arg_types, resolved_type, &block)
      Methods[name] = Intrinsic.new("#{self.name}##{name}", arg_types, resolved_type, &block)
    end

    crystal_define_method 'class', Def.new("Int#class", [Var.new("self")], Int.new(object_id))
    crystal_define_method :'+@', Def.new("Int#+@", [Var.new("self")], Ref.new("self"))
    crystal_define_method :'-@', Def.new("Int#-@", [Var.new("self")], Call.new(Int.new(0), :'-', Ref.new("self")))

    [
      ['+', 'add'],
      ['-', 'sub'],
      ['*', 'mul'],
      ['/', 'sdiv'],
    ].each do |op, method|
      class_eval %Q(
        crystal_define_intrinsic(:'#{op}', [Int, Int], Int) { |mod, fun| mod.builder.#{method} fun.params[0], fun.params[1], '#{method}tmp' }
      )
    end

    [
      ["<", "slt"],
      ["<=", "sle"],
      [">", "sgt"],
      [">=", "sge"],
      ["==", "eq"],
    ].each do |op, method|
      class_eval %Q(
        crystal_define_intrinsic(:'#{op}', [Int, Int], Int) do |mod, fun|
          cond = mod.builder.icmp :#{method}, fun.params[0], fun.params[1], '#{method}tmp'
          mod.builder.zext(cond, LLVM::Int, 'booltmp')
        end
      )
    end

    def self.find_method(name)
      method = Methods[name]
      method ? method.dup : nil
    end
  end
end
