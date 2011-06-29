module Crystal
  class ASTNode
    def self.find_method(name)
      nil
    end
  end

  class Intrinsic < Def
    def initialize(name, args_length, resolved_type, &block)
      @name = name
      @args = args_length.times.map{|i| Var.new("x#{i}")}
      @resolved_type = resolved_type
      @block = block
    end

    def codegen_body(mod, fun)
      @block.call mod, fun
    end
  end

  class Int
    def self.name; "Int"; end
    def self.to_s; name; end

    Methods = {}
    def self.crystal_define_method(name, method)
      Methods[name] = method
    end

    def self.crystal_define_intrinsic(name, args_length, resolved_type, &block)
      Methods[name] = Intrinsic.new("#{self.name}##{name}", args_length, resolved_type, &block)
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
        crystal_define_intrinsic(:'#{op}', 2, Int) { |mod, fun| mod.builder.#{method} fun.params[0], fun.params[1], '#{method}tmp' }
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
        crystal_define_intrinsic(:'#{op}', 2, Int) do |mod, fun|
          cond = mod.builder.icmp :#{method}, fun.params[0], fun.params[1], '#{method}tmp'
          mod.builder.zext(cond, Crystal::DefaultType, 'booltmp')
        end
      )
    end

    def self.find_method(name)
      method = Methods[name]
      method ? method.dup : nil
    end
  end
end
